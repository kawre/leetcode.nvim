local path = require("plenary.path")
local log = require("leetcode.logger")

local config = require("leetcode.config")
local file = config.home:joinpath(".cookie")

---@class lc.Cookie
---@field csrftoken string
---@field leetcode_session string
local cookie = {}

---@param str string
---
---@return lc.Cookie
function cookie.update(str)
    local ok, t = pcall(cookie.parse, str)
    assert(ok, "Cookie parse failed")

    file:write(str, "w")

    local auth_api = require("leetcode.api.auth")
    local a_ok, err = pcall(auth_api.user)

    if not a_ok then
        cookie.delete()
        error(err)
    end

    return t
end

function cookie.delete() pcall(path.rm, file) end

---@return lc.Cookie | nil
function cookie.get()
    local r_ok, contents = pcall(path.read, file)
    if not r_ok then return end

    local p_ok, c = pcall(cookie.parse, contents)
    if not p_ok then return end

    return c
end

---@param cookie_str string
---
function cookie.parse(cookie_str)
    local c = {}

    local csrf_ok, csrf = pcall(string.match, cookie_str, "csrftoken=[^;]+")
    assert(csrf_ok and csrf, "Bad csrf token format")
    c.csrftoken = csrf:sub(11)

    local ls_ok, ls = pcall(string.match, cookie_str, "LEETCODE_SESSION=[^;]+")
    assert(ls_ok and ls, "Bad leetcode session token format")
    c.leetcode_session = ls:sub(18)

    return c
end

return cookie
