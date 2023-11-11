local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc.AuthApi
local M = {}

local usr_fields = [[
    id: userId
    name: username
    is_signed_in: isSignedIn
    is_premium: isPremium
    is_verified: isVerified
]]

---@return lc.UserStatus, lc.err
function M.user(cb)
    local query = string.format(
        [[
            query globalData {
              userStatus { %s }
            }
        ]],
        usr_fields
    )

    if cb then
        utils.query(query, {}, function(res, err) cb(M.handle(res, err)) end)
    else
        return M.handle(utils.query(query))
    end
end

function M.handle(res, err)
    local auth = res.data.userStatus

    local msgs = {}
    if not auth.is_signed_in then table.insert(msgs, "Sign-in failed") end
    if not auth.is_verified then
        table.insert(msgs, "Please verify your email address in order to use your account")
    end

    if not vim.tbl_isempty(msgs) then
        require("leetcode.cache.cookie").delete()
        err = err or {}
        err.msgs = msgs
    end

    config.auth = auth
    return log.debug(auth), err
end

return M
