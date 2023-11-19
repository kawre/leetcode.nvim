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

    local msgs = {}
    if not auth.is_signed_in then table.insert(msgs, t("Sign-in failed")) end
    if not auth.is_verified then
        table.insert(msgs, t("Please verify your email address in order to use your account"))
    end

    if not vim.tbl_isempty(msgs) then
        err = vim.tbl_deep_extend("force", err or {}, { msgs = msgs })
        return nil, err
    else
        config.auth = log.debug(auth) ---@diagnostic disable-line
        return auth
    end
end

return Auth
