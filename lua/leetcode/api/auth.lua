local config = require("leetcode.config")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")
local urls = require("leetcode.api.urls")

---@class leet.api.auth
local M = {}

---@private
---@return lc.UserStatus, lc.err
local function handle(res, err)
    if err then
        return res, err
    end

    local auth = res.data.userStatus
    err = {}

    if (not config.is_cn and auth.id == vim.NIL) or (config.is_cn and auth.slug == vim.NIL) then
        err.msg = "Cookie expired?"
    elseif not auth.is_signed_in then
        err.msg = "Sign-in failed"
    elseif not auth.is_verified then
        err.msg = "Please verify your email address in order to use your account"
    end

    if err.msg then
        require("leetcode.cmd").delete_cookie()
        return nil, err
    end

    config.auth = log.debug(auth) ---@diagnostic disable-line
    Leet.auth:set(function()
        return { auth = Markup.list(auth) }
    end)
    return auth
end

---@return lc.UserStatus, lc.err
function M.user(cb)
    local query = queries.auth

    if cb then
        Leet.api.query(query, {}, {
            callback = function(res, err)
                cb(handle(res, err))
            end,
            endpoint = urls.auth,
        })
    else
        return handle(Leet.api.query(query, {}, {
            endpoint = urls.auth,
        }))
    end
end

return M
