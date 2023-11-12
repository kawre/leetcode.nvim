local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")

---@class lc.AuthApi
local M = {}

---@return lc.UserStatus, lc.err
function M.user(cb)
    local query = queries.auth()

    if cb then
        utils.query(query, {}, function(res, err) cb(M.handle(res, err)) end)
    else
        return M.handle(utils.query(query))
    end
end

function M.handle(res, err)
    if err then return res, err end
    local auth = res.data.userStatus

    local msgs = {}
    if not auth.is_signed_in then table.insert(msgs, "Sign-in failed") end
    if not auth.is_verified then
        table.insert(msgs, "Please verify your email address in order to use your account")
    end

    if not vim.tbl_isempty(msgs) then
        err = vim.tbl_deep_extend("force", err or {}, { msgs = msgs })
        require("leetcode.cache.cookie").delete()
    end

    config.auth = auth
    return log.debug(auth), err
end

return M
