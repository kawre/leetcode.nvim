local path = require("plenary.path")

local log = require("leetcode.logger")
local file = path:new(vim.fn.stdpath("data") .. "/leetcode/.cookie")

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
    local auth = auth_api.user()

    if not auth.is_signed_in then
        cookie.delete()
        error("Invalid cookie")
    end

    return t
end

function cookie.delete() file:rm() end

---@return lc.Cookie | nil
function cookie.get()
    local r_ok, contents = pcall(path.read, file)
    if not r_ok then return end

    local pok, c = pcall(cookie.parse, contents)
    if not pok then return end

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
