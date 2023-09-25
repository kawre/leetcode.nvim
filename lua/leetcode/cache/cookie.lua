local path = require("plenary.path")

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

    -- if not file:exists() then file:touch() end
    file:write(str, "w")

    return t
end

---@return lc.Cookie | nil
function cookie.get()
    local r_ok, contents = pcall(path.read, file)
    if not r_ok then return end

    local n_ok, c = pcall(cookie.update, contents)
    if not n_ok then return end

    return c
end

function cookie.delete() file:rm() end

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
