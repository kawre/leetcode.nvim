local path = require("plenary.path")

local config = require("leetcode.config")
---@type Path
local file = config.storage.cache:joinpath(("cookie%s"):format(config.is_cn and "_cn" or ""))

local hist = {}

---@class lc.cache.Cookie
---@field csrftoken string
---@field leetcode_session string
---@field str string

---@class leet.cache.cookie
local M = {}

---@param str string
---@return string|nil
function M.set(str)
    local _, cerr = M.parse(str)
    if cerr then
        return cerr
    end

    file:write(str, "w")
    local auth_api = require("leetcode.api.auth")
    local _, aerr = auth_api.user()

    if aerr then
        return aerr.msg
    end
end

---@return boolean
function M.delete()
    if not file:exists() then
        return false
    end
    return pcall(path.rm, file)
end

---@return string|nil
function M.read()
    local contents = file:read()

    if not contents or type(contents) ~= "string" then
        return
    end

    return select(1, contents:gsub("^%s*(.-)%s*$", "%1"))
end

---@return lc.cache.Cookie | nil
function M.get()
    if not file:exists() then
        return
    end

    local fstats = file:_stat()
    local ftime = fstats.mtime.sec

    local hcookie = hist[ftime]
    if hcookie then
        return hcookie
    end

    local contents = M.read()
    if not contents then
        require("leetcode.command").delete_cookie()
        return
    end

    local cookie = M.parse(contents)
    if not cookie then
        require("leetcode.command").delete_cookie()
        return
    end

    hist[ftime] = cookie
    return cookie
end

---@param str string
---
---@return lc.cache.Cookie|nil, string|nil
function M.parse(str)
    local csrf = str:match("csrftoken=([^;]+)")
    if not csrf or csrf == "" then
        return nil, "Bad csrf token format"
    end

    local ls = str:match("LEETCODE_SESSION=([^;]+)")
    if not ls or ls == "" then
        return nil, "Bad leetcode session token format"
    end

    return { csrftoken = csrf, leetcode_session = ls, str = str }
end

return M
