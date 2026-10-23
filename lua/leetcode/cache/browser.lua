local config = require("leetcode.config")

-- Reads the leetcode session from a local browser's cookie store, so signing in is
-- just signing in on the website.
--
-- Linux only for now. Chromium-based browsers encrypt cookies with AES-128-CBC keyed
-- by PBKDF2-HMAC-SHA1 of a password from the OS keyring (via `secret-tool`); the
-- legacy `v10` and current `v11` prefixes share this scheme. Firefox stores cookies
-- as-is. Decryption uses the system libcrypto through LuaJIT's ffi, so no external
-- Lua rock is needed. Requirements: `sqlite3`, `secret-tool` and an OpenSSL libcrypto.
--
-- The cookie store is queried on a snapshot copy, because browsers keep it locked
-- and Firefox keeps recent writes in its WAL.

local ok_ffi, ffi = pcall(require, "ffi")
if not ok_ffi then
    return {}
end

local sysname = vim.loop.os_uname().sysname

local BROWSERS
if sysname == "Linux" then
    BROWSERS = {
        {
            app = "Chromium",
            glob = ".config/chromium/*/Cookies",
            keyring = "chromium",
            bin = "chromium",
        },
        {
            app = "Google Chrome",
            glob = ".config/google-chrome/*/Cookies",
            keyring = "chrome",
            bin = "google-chrome-stable",
        },
        {
            app = "Brave Browser",
            glob = ".config/BraveSoftware/Brave-Browser/*/Cookies",
            keyring = "brave",
            bin = "brave",
        },
        {
            app = "Microsoft Edge",
            glob = ".config/microsoft-edge/*/Cookies",
            keyring = "microsoft-edge",
            bin = "microsoft-edge",
        },
        {
            app = "Firefox",
            glob = ".mozilla/firefox/*/cookies.sqlite",
            firefox = true,
            bin = "firefox",
        },
    }
end

local hosts = ("('leetcode.%s', '.leetcode.%s')"):format(config.domain, config.domain)
local chromium_sql = "select host_key, name, value, hex(encrypted_value) from cookies where host_key in "
    .. hosts
    .. " order by expires_utc"
local firefox_sql = "select host, name, value from moz_cookies where host in "
    .. hosts
    .. " order by expiry"

local function unhex(hex)
    return (hex:gsub("%x%x", function(h)
        return string.char(tonumber(h, 16))
    end))
end

-- keyring -------------------------------------------------------------------

local passwords = {}

---@param app string keyring `application` attribute of the browser
---@return string|nil password
local function keyring_password(app)
    if passwords[app] == nil then
        local pass = vim.fn.system({ "secret-tool", "lookup", "application", app })
        if vim.v.shell_error ~= 0 or pass == "" then
            -- `lookup` fails on a locked collection where `search` still succeeds
            local out = vim.fn.system({ "secret-tool", "search", "--all", "application", app })
            if vim.v.shell_error == 0 then
                pass = out:match("secret%s*=%s*(%S+)") or ""
            end
        end
        pass = vim.trim(pass)
        if pass == "" then
            -- chromium's `--password-store=basic` fallback password
            pass = "peanuts"
        end
        passwords[app] = pass ~= "" and pass or nil
    end
    return passwords[app]
end

-- libcrypto -------------------------------------------------------------------

local C
for _, name in ipairs({ "libcrypto.so.3", "libcrypto.so", "crypto" }) do
    local ok, lib = pcall(ffi.load, name)
    if ok then
        C = lib
        break
    end
end

pcall(
    ffi.cdef,
    [[
    typedef struct evp_cipher_ctx_st EVP_CIPHER_CTX;
    typedef struct evp_md_st EVP_MD;
    typedef struct engine_st ENGINE;
    typedef struct evp_cipher_st EVP_CIPHER;
    const EVP_MD *EVP_sha1(void);
    int PKCS5_PBKDF2_HMAC(const char *pass, int passlen, const char *salt,
        int saltlen, int iter, const EVP_MD *digest, int keylen, unsigned char *out);
    unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md);
    EVP_CIPHER_CTX *EVP_CIPHER_CTX_new(void);
    void EVP_CIPHER_CTX_free(EVP_CIPHER_CTX *a);
    const EVP_CIPHER *EVP_aes_128_cbc(void);
    int EVP_DecryptInit_ex(EVP_CIPHER_CTX *ctx, const EVP_CIPHER *cipher,
        ENGINE *impl, const unsigned char *key, const unsigned char *iv);
    int EVP_DecryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
        const unsigned char *in, int inl);
    int EVP_DecryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl);
]]
)

local SALT, IV, ITER = "saltysalt", (" "):rep(16), 1

local function sha256(s)
    local buf = ffi.new("unsigned char[32]")
    C.SHA256(ffi.cast("const unsigned char*", s), #s, buf)
    return ffi.string(buf, 32)
end

---@param pass string keyring password
---@return string|nil 16-byte AES-128 key
local function derive_key(pass)
    local k = ffi.new("unsigned char[16]")
    local rc = C.PKCS5_PBKDF2_HMAC(pass, #pass, SALT, #SALT, ITER, C.EVP_sha1(), 16, k)
    if rc ~= 1 then
        return nil
    end
    return ffi.string(k, 16)
end

---@param data string ciphertext, without the version prefix
---@param k string 16-byte key
---@return string|nil plaintext
local function aes_cbc_decrypt(data, k)
    local ctx = C.EVP_CIPHER_CTX_new()
    if C.EVP_DecryptInit_ex(ctx, C.EVP_aes_128_cbc(), nil,
        ffi.cast("const unsigned char*", k),
        ffi.cast("const unsigned char*", IV)) ~= 1 then
        C.EVP_CIPHER_CTX_free(ctx)
        return nil
    end
    local out = ffi.new("unsigned char[?]", #data + 16)
    local outl = ffi.new("int[1]")
    if C.EVP_DecryptUpdate(ctx, out, outl,
        ffi.cast("const unsigned char*", data), #data) ~= 1 then
        C.EVP_CIPHER_CTX_free(ctx)
        return nil
    end
    local total = outl[0]
    if C.EVP_DecryptFinal_ex(ctx, out + total, outl) ~= 1 then
        C.EVP_CIPHER_CTX_free(ctx)
        return nil
    end
    total = total + outl[0]
    C.EVP_CIPHER_CTX_free(ctx)
    return ffi.string(out, total)
end

---@param host string cookie's host_key
---@param value string encrypted_value with `v10`/`v11` prefix
---@param pass string|nil keyring password
---@return string cookie value, "" on failure
local function chromium_decrypt(host, value, pass)
    if not pass then
        return ""
    end
    local prefix = value:sub(1, 3)
    if prefix ~= "v10" and prefix ~= "v11" then
        return ""
    end
    local k = derive_key(pass)
    local plain = k and aes_cbc_decrypt(value:sub(4), k) or nil
    if not plain then
        return ""
    end
    -- recent cookie stores prefix the value with sha256(host_key)
    if #plain > 32 and plain:sub(1, 32) == sha256(host) then
        plain = plain:sub(33)
    end
    return plain
end

-- stores -------------------------------------------------------------------

---@param db string
---@param sql string
---@return string[][] rows
local function query(db, sql)
    -- browsers keep the store locked and Firefox keeps recent writes in the WAL: query a copy
    local tmp = vim.fn.tempname()
    vim.loop.fs_copyfile(db, tmp)
    for _, suffix in ipairs({ "-wal", "-shm", "-journal" }) do
        vim.loop.fs_copyfile(db .. suffix, tmp .. suffix)
    end
    local out = vim.fn.systemlist({ "sqlite3", "-separator", "\t", tmp, sql })
    vim.fn.delete(tmp)
    for _, suffix in ipairs({ "-wal", "-shm", "-journal" }) do
        vim.fn.delete(tmp .. suffix)
    end
    if vim.v.shell_error ~= 0 then
        return {}
    end
    return vim.tbl_map(function(row)
        return vim.split(row, "\t")
    end, out)
end

---@return { db: string, browser: table }[] most recently used first
local function stores()
    local list = {}
    for _, browser in ipairs(BROWSERS) do
        for _, db in ipairs(vim.fn.glob(vim.loop.os_homedir() .. "/" .. browser.glob, false, true)) do
            table.insert(list, { db = db, browser = browser, time = vim.fn.getftime(db) })
        end
    end
    table.sort(list, function(a, b)
        return a.time > b.time
    end)
    return list
end

---@param db string
---@param browser table
---@return string[][] { name, value } rows
local function cookies(db, browser)
    local rows = query(db, browser.firefox and firefox_sql or chromium_sql)
    return vim.tbl_map(function(row)
        if browser.firefox then
            return { row[2], row[3] }
        end
        local host, name, value, hex = row[1], row[2], row[3], row[4]
        if value == "" and hex ~= "" then
            value = chromium_decrypt(host, unhex(hex), keyring_password(browser.keyring))
        end
        return { name, value }
    end, rows)
end

---@param rows string[][] { name, value } ordered by expiry
---@return string|nil
local function cookie_str(rows)
    local map = {}
    for _, row in ipairs(rows) do
        map[row[1]] = row[2] ~= "" and row[2] or nil
    end
    if not (map.csrftoken and map.LEETCODE_SESSION) then
        return nil
    end
    return ("csrftoken=%s; LEETCODE_SESSION=%s"):format(map.csrftoken, map.LEETCODE_SESSION)
end

-- browser -------------------------------------------------------------------

---@class lc.BrowserCookie
local Browser = {}

---The supported browser used most recently, to sign in with (none outside Linux)
---@return string|nil app name
function Browser.app()
    local store = stores()[1]
    return store and store.browser.app
end

---@param app string
---@param url string
function Browser.open(app, url)
    for _, browser in ipairs(BROWSERS) do
        if browser.app == app then
            vim.fn.jobstart({ browser.bin, url }, { detach = true })
            return
        end
    end
    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
end

---Cookie string from the most recently used browser profile that is signed in to leetcode
---@return string|nil
function Browser.get()
    if not C then
        return nil
    end
    for _, store in ipairs(stores()) do
        local str = cookie_str(cookies(store.db, store.browser))
        if str then
            return str
        end
    end
end

return Browser
