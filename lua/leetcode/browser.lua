local config = require("leetcode.config")
local log = require("leetcode.logger")

local uv = vim.uv or vim.loop

---Sign in through a dedicated browser window.
---
---A Chromium-based browser is started with its own profile, stored in the plugin cache,
---so the user's regular browser profile, cookies and keyring are never touched.
---Once the user signs in to LeetCode in that window, the session cookie is read over the
---Chrome DevTools Protocol (`--remote-debugging-pipe`) and the window is closed.
---@class lc.Browser
local Browser = {}

local POLL_INTERVAL = 1000 -- ms between cookie checks
local CLOSE_TIMEOUT = 5000 -- ms to wait for a graceful browser exit before killing it

---@type lc.Browser.Session|nil
local active

---@return string[]
local function candidates()
    if vim.fn.has("mac") == 1 then
        local apps = { "Google Chrome", "Chromium", "Brave Browser", "Microsoft Edge", "Vivaldi" }
        return vim.tbl_map(function(app)
            return ("/Applications/%s.app/Contents/MacOS/%s"):format(app, app)
        end, apps)
    end

    if vim.fn.has("win32") == 1 then
        local roots = {
            vim.env["PROGRAMFILES"],
            vim.env["PROGRAMFILES(X86)"],
            vim.env["LOCALAPPDATA"],
        }
        local exes = {
            "Google/Chrome/Application/chrome.exe",
            "Microsoft/Edge/Application/msedge.exe",
            "BraveSoftware/Brave-Browser/Application/brave.exe",
            "Chromium/Application/chrome.exe",
        }

        local paths = {}
        for _, root in ipairs(roots) do
            for _, exe in ipairs(exes) do
                table.insert(paths, root .. "/" .. exe)
            end
        end
        return paths
    end

    return {
        "chromium",
        "chromium-browser",
        "google-chrome",
        "google-chrome-stable",
        "brave",
        "brave-browser",
        "microsoft-edge",
        "microsoft-edge-stable",
        "vivaldi",
        "vivaldi-stable",
    }
end

---@return string|nil path, string|nil err
function Browser.find()
    local browser = (config.user.login or {}).browser

    if browser and browser ~= "" then
        local path = vim.fn.exepath(vim.fn.expand(browser))
        if path == "" then
            return nil, ("Browser `%s` is not executable"):format(browser)
        end
        return path
    end

    for _, name in ipairs(candidates()) do
        local path = vim.fn.exepath(name)
        if path ~= "" then
            return path
        end
    end

    return nil, "No Chromium-based browser found, set `login.browser` in your config"
end

---Profile used by the sign-in browser, kept between sign-ins.
---@return string
function Browser.profile_dir()
    return config.storage.cache:joinpath("browser").filename
end

---@param profile string
---@param url string
---@return string[]
function Browser.args(profile, url)
    return {
        "--remote-debugging-pipe",
        "--user-data-dir=" .. profile,
        "--no-first-run",
        "--no-default-browser-check",
        "--password-store=basic", -- Linux: don't use the system keyring
        "--use-mock-keychain", -- macOS: don't use the system keychain
        url,
    }
end

---Build a cookie string from the browser cookies of the current LeetCode domain.
---
---@param cookies table[] `Network.Cookie` objects
---@return string|nil cookie, string|nil session
function Browser.extract(cookies)
    local domain = "leetcode." .. config.domain
    local found = {}

    for _, c in ipairs(cookies or {}) do
        local host = (c.domain or ""):gsub("^%.", "")
        local wanted = c.name == "csrftoken" or c.name == "LEETCODE_SESSION"

        if host == domain and wanted and type(c.value) == "string" and c.value ~= "" then
            found[c.name] = c.value
        end
    end

    if found.csrftoken and found.LEETCODE_SESSION then
        local session = found.LEETCODE_SESSION
        return ("csrftoken=%s; LEETCODE_SESSION=%s"):format(found.csrftoken, session), session
    end
end

---@class lc.Browser.Session
---@field handle uv.uv_process_t|nil
---@field input uv.uv_pipe_t browser reads DevTools commands from it (fd 3)
---@field output uv.uv_pipe_t browser writes DevTools messages to it (fd 4)
---@field timer uv.uv_timer_t
---@field buffer string
---@field id integer
---@field callbacks table<integer, fun(result?: table, err?: table)>
---@field tried table<string, boolean> session tokens that were already validated
---@field busy boolean a cookie check or validation is in flight
---@field validating boolean
---@field exited boolean
---@field done boolean
---@field cb fun(success: boolean, err?: string)
local Session = {}
Session.__index = Session

---Send a DevTools command to the browser.
---
---@param method string
---@param params? table
---@param callback? fun(result?: table, err?: table)
function Session:send(method, params, callback)
    if self.exited or self.input:is_closing() then
        return
    end

    self.id = self.id + 1
    if callback then
        self.callbacks[self.id] = callback
    end

    local msg = vim.json.encode({ id = self.id, method = method, params = params })
    self.input:write(msg .. "\0")
end

---Messages are JSON objects delimited by `\0`.
---@private
---@param data string
function Session:on_data(data)
    self.buffer = self.buffer .. data

    while true do
        local idx = self.buffer:find("\0", 1, true)
        if not idx then
            break
        end

        local raw = self.buffer:sub(1, idx - 1)
        self.buffer = self.buffer:sub(idx + 1)

        local ok, msg = pcall(vim.json.decode, raw)
        if ok and type(msg) == "table" and msg.id then
            local callback = self.callbacks[msg.id]
            self.callbacks[msg.id] = nil

            if callback then
                callback(msg.result, msg.error)
            end
        end
    end
end

---@private
function Session:poll()
    if self.busy or self.done then
        return
    end
    self.busy = true

    self:send("Storage.getCookies", nil, function(result)
        local cookie, session = Browser.extract(result and result.cookies)

        if not cookie or self.tried[session] then
            self.busy = false
            return
        end

        self.tried[session] = true
        self.validating = true
        vim.schedule(function()
            self:validate(cookie)
        end)
    end)
end

---@private
---@param cookie string
function Session:validate(cookie)
    local err = require("leetcode.cache.cookie").set(cookie)
    self.validating = false

    if not err then
        return self:finish(true)
    end

    log.debug("Browser sign-in: cookie rejected: " .. err)
    if self.exited then
        return self:finish(false, err)
    end
    self.busy = false
end

---@private
---@param success boolean
---@param err? string
function Session:finish(success, err)
    if self.done then
        return
    end
    self.done = true

    if not self.timer:is_closing() then
        self.timer:stop()
    end

    if not self.exited then
        if success then
            -- graceful exit lets the browser save its profile
            self:send("Browser.close")
            vim.defer_fn(function()
                self:kill()
            end, CLOSE_TIMEOUT)
        else
            self:kill()
        end
    end

    vim.schedule(function()
        self.cb(success, err)
    end)
end

function Session:kill()
    if self.handle and not self.handle:is_closing() then
        pcall(self.handle.kill, self.handle, "sigterm")
    end
end

---@private
function Session:on_exit()
    self.exited = true

    for _, h in ipairs({ self.input, self.output, self.timer, self.handle }) do
        if h and not h:is_closing() then
            h:close()
        end
    end

    if active == self then
        active = nil
    end

    -- a pending validation decides the outcome itself
    if not self.validating then
        self:finish(false, "Browser was closed before signing in")
    end
end

---@return lc.Browser.Session|nil
function Browser.active()
    return active
end

local leave_autocmd

---Open a browser window to sign in to LeetCode.
---`cb` is called once the user is signed in or the browser is closed.
---
---@param cb fun(success: boolean, err?: string)
---@return boolean launched, string|nil err
function Browser.login(cb)
    if active then
        return false, "Browser sign-in is already in progress"
    end

    local exe, ferr = Browser.find()
    if not exe then
        return false, ferr
    end

    local profile = Browser.profile_dir()
    vim.fn.mkdir(profile, "p")
    local url = ("https://leetcode.%s/accounts/login/"):format(config.domain)

    local session = setmetatable({
        input = uv.new_pipe(false),
        output = uv.new_pipe(false),
        timer = uv.new_timer(),
        buffer = "",
        id = 0,
        callbacks = {},
        tried = {},
        busy = false,
        validating = false,
        exited = false,
        done = false,
        cb = cb,
    }, Session)

    local handle, serr = uv.spawn(exe, {
        args = Browser.args(profile, url),
        stdio = { nil, nil, nil, session.input, session.output },
        hide = true,
    }, function()
        session:on_exit()
    end)

    if not handle then
        session.input:close()
        session.output:close()
        session.timer:close()
        return false, ("Failed to launch `%s`: %s"):format(exe, serr)
    end

    session.handle = handle
    active = session

    session.output:read_start(function(err, data)
        if not err and data then
            session:on_data(data)
        end
    end)

    session.timer:start(POLL_INTERVAL, POLL_INTERVAL, function()
        session:poll()
    end)

    if not leave_autocmd then
        leave_autocmd = vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                if active then
                    active:kill()
                end
            end,
        })
    end

    return true
end

---Forget the LeetCode session kept by the sign-in browser profile.
function Browser.clear()
    if active then
        return
    end
    vim.fn.delete(Browser.profile_dir(), "rf")
end

return Browser
