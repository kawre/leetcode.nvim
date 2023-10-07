local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc.AuthApi
local M = {}

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

    config.auth = res["userStatus"]
    log.debug({ title = "user auth", body = config.auth })
    return config.auth
end

return M
