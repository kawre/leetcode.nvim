local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc.AuthApi
local M = {}

local function update_cfg_auth(res)
    config.auth = res["userStatus"]
    log.debug({ title = "user auth", body = config.auth })
    return config.auth
end

---@return lc.UserAuth
function M.user()
    local query = [[
        query globalData {
          userStatus {
            id: userId
            is_signed_in: isSignedIn
            is_premium: isPremium
            name: username

            isVerified
            activeSessionId
            isMockUser
          }
        }
    ]]

    local ok, res = pcall(utils.query, query)
    if not ok then return {} end

    return update_cfg_auth(res)
end

function M._user(cb)
    local query = [[
        query globalData {
          userStatus {
            id: userId
            is_signed_in: isSignedIn
            is_premium: isPremium
            name: username

            isVerified
            activeSessionId
            isMockUser
          }
        }
    ]]

    if not require("leetcode.cache.cookie").get() then return cb() end
    utils._query({ query = query }, function(res)
        update_cfg_auth(res)
        cb()
    end)
end

return M
