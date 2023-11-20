local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")
local t = require("leetcode.translator")
local urls = require("leetcode.api.urls")

---@class lc.AuthApi
local Auth = {}

---@return lc.UserStatus|nil, lc.err|nil
function Auth.user(cb)
    local query = queries.auth

    if cb then
        utils.query(query, {}, {
            callback = function(res, err) cb(Auth.handle(res, err)) end,
            endpoint = urls.auth,
        })
    else
        return Auth.handle(utils.query(query, {}, {
            endpoint = urls.auth,
        }))
    end
end

---@private
---@return lc.UserStatus|nil, lc.err|nil
function Auth.handle(res, err)
    if err then return res, err end

    local auth = res.data.userStatus
    err = {}

    if not auth.id then
        err.msg = t("Session expired?")
    elseif not auth.is_signed_in then
        err.msg = t("Sign-in failed")
    elseif not auth.is_verified then
        err.msg = t("Please verify your email address in order to use your account")
    end
    if err.msg then return nil, err end

    config.auth = log.debug(auth) ---@diagnostic disable-line
    return auth
end

return Auth
