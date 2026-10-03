local ffi = require("ffi")
local config = require("leetcode.config")

-- Reads the leetcode session from a local browser's cookie store, so signing in is just signing
-- in on the website. Chromium-based browsers encrypt cookies with AES-128-CBC keyed by
-- PBKDF2-SHA1 of a password from the OS keyring; Firefox stores them as is.
-- macOS only for now: another platform needs its own `dir`/`browsers`, `key` (keyring and
-- iterations), crypto backend for `key`/`decrypt`, and `Browser.open`.

-- CommonCrypto, part of macOS's libSystem
pcall(
    ffi.cdef,
    [[
    int CCKeyDerivationPBKDF(uint32_t alg, const char *pass, size_t pass_len, const char *salt,
        size_t salt_len, uint32_t prf, unsigned rounds, uint8_t *key, size_t key_len);
    int CCCrypt(uint32_t op, uint32_t alg, uint32_t opts, const char *key, size_t key_len,
        const char *iv, const char *in, size_t in_len, uint8_t *out, size_t out_size, size_t *out_len);
]]
)

local dir = vim.loop.os_homedir() .. "/Library/Application Support/"

-- `keychain`: Chromium-based, cookies encrypted with the "<keychain> Safe Storage" password
local browsers = {
    { app = "Google Chrome", glob = "Google/Chrome/*/Cookies", keychain = "Chrome" },
    { app = "Brave Browser", glob = "BraveSoftware/Brave-Browser/*/Cookies", keychain = "Brave" },
    { app = "Microsoft Edge", glob = "Microsoft Edge/*/Cookies", keychain = "Microsoft Edge" },
    { app = "Arc", glob = "Arc/User Data/*/Cookies", keychain = "Arc" },
    { app = "Chromium", glob = "Chromium/*/Cookies", keychain = "Chromium" },
    { app = "Firefox", glob = "Firefox/Profiles/*/cookies.sqlite" },
}

local hosts = ("('leetcode.%s', '.leetcode.%s')"):format(config.domain, config.domain)
local chromium_sql = "select value from meta where key = 'version';"
    .. "select name, value, hex(substr(encrypted_value, 4)) from cookies where host_key in "
    .. hosts
    .. " order by expires_utc"
local firefox_sql = "select name, value from moz_cookies where host in "
    .. hosts
    .. " order by expiry"

---@param hex string
local function unhex(hex)
    return (hex:gsub("..", function(h)
        return string.char(tonumber(h, 16))
    end))
end

local keys = {}

---@param name string browser's Keychain name
local function key(name)
    if keys[name] == nil then
        local service = name .. " Safe Storage"
        local pass = vim.fn.system({ "security", "find-generic-password", "-w", "-s", service })
        pass = vim.trim(pass)
        local k = ffi.new("uint8_t[16]")
        -- PBKDF2, HMAC-SHA1
        local ok = vim.v.shell_error == 0
            and ffi.C.CCKeyDerivationPBKDF(2, pass, #pass, "saltysalt", 9, 1, 1003, k, 16) == 0
        keys[name] = ok and ffi.string(k, 16)
    end
    return keys[name]
end

---@param data string ciphertext, without the "v10" prefix
---@param k string
local function decrypt(data, k)
    local out, len = ffi.new("uint8_t[?]", #data), ffi.new("size_t[1]")
    -- decrypt, AES-128, PKCS7 padding
    local rc = ffi.C.CCCrypt(1, 0, 1, k, 16, (" "):rep(16), data, #data, out, #data, len)
    return rc == 0 and ffi.string(out, len[0]) or ""
end

---@param db string
---@param sql string
---@return string[][]
local function query(db, sql)
    -- browsers keep the store locked and Firefox keeps recent writes in the WAL: query a copy
    local tmp = vim.fn.tempname()
    vim.loop.fs_copyfile(db, tmp)
    vim.loop.fs_copyfile(db .. "-wal", tmp .. "-wal")
    local out = vim.fn.systemlist({ "sqlite3", "-separator", "\t", tmp, sql })
    vim.fn.delete(tmp)
    vim.fn.delete(tmp .. "-wal")
    return vim.tbl_map(function(row)
        return vim.split(row, "\t")
    end, vim.v.shell_error == 0 and out or {})
end

---@return { db: string, browser: table }[] most recently used first
local function stores()
    local list = {}
    for _, browser in ipairs(browsers) do
        for _, db in ipairs(vim.fn.glob(dir .. browser.glob, false, true)) do
            table.insert(list, { db = db, browser = browser, time = vim.fn.getftime(db) })
        end
    end
    table.sort(list, function(a, b)
        return a.time > b.time
    end)
    return list
end

---@param db string
---@param keychain string
local function chromium_cookies(db, keychain)
    local rows = query(db, chromium_sql)
    local version = tonumber((table.remove(rows, 1) or {})[1]) or 0
    for _, row in ipairs(rows) do
        local k = row[2] == "" and row[3] ~= "" and key(keychain)
        if k then
            -- since db version 24 the value is prefixed with sha256(host_key)
            row[2] = decrypt(unhex(row[3]), k):sub(version >= 24 and 33 or 1)
        end
    end
    return rows
end

---@param rows string[][] { name, value } ordered by expiry
local function cookie_str(rows)
    local cookies, parts = {}, {}
    for _, row in ipairs(rows) do
        cookies[row[1]] = row[2] ~= "" and row[2] or nil
    end
    if not (cookies.csrftoken and cookies.LEETCODE_SESSION) then
        return
    end
    for name, value in pairs(cookies) do
        table.insert(parts, name .. "=" .. value)
    end
    return table.concat(parts, "; ")
end

---@class lc.BrowserCookie
local Browser = {}

---The supported browser used most recently, to sign in with (none outside macOS)
---@return string|nil app name
function Browser.app()
    local store = stores()[1]
    return store and store.browser.app
end

---@param app string
---@param url string
function Browser.open(app, url)
    vim.fn.jobstart({ "open", "-a", app, url }, { detach = true })
end

---Cookie string from the most recently used browser profile that is signed in to leetcode
---@return string|nil
function Browser.get()
    for _, store in ipairs(stores()) do
        local keychain = store.browser.keychain
        local rows = keychain and chromium_cookies(store.db, keychain)
            or query(store.db, firefox_sql)
        local str = cookie_str(rows)
        if str then
            return str
        end
    end
end

return Browser
