local path = require("plenary.path")

local file = path:new(vim.fn.stdpath("data") .. "/leetcode/.cookie")

---@class lc.Cookie
---@field csrftoken string
---@field leetcode_session string

local M = {}

---@param cookie_str string
---
---@return lc.Cookie
function M.new(cookie_str)
    local _, t = assert(pcall(M.parse, cookie_str))

    if not file:exists() then file:touch() end
    file:write(cookie_str, "w")

    return t
end

---@return lc.Cookie | nil
function M.read()
    local r_ok, contents = pcall(path.read, file)
    if not r_ok then return end

    local n_ok, cookie = pcall(M.new, contents)
    if not n_ok then return end

    return cookie
end

function M.delete() file:rm() end

---@param cookie_str string
---
function M.parse(cookie_str)
    local cookie = {}

    local csrf_ok, csrf = pcall(string.match, cookie_str, "csrftoken=[^;]+")
    assert(csrf_ok and csrf, "Bad csrf token format")
    cookie.csrftoken = csrf:sub(11)

    local ls_ok, ls = pcall(string.match, cookie_str, "LEETCODE_SESSION=[^;]+")
    assert(ls_ok and ls, "Bad leetcode session token format")
    cookie.leetcode_session = ls:sub(18)

    return cookie
end

return M
