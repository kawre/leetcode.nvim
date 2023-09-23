local utils = require("leetcode.api.graphql.utils")
local config = require("leetcode.config")

---@class lc.AuthApi
local M = {}

---@class lc.UserStatus
---@field username string
---@field is_signed_in boolean
---@field is_premium boolean
---@field user_id integer

---@return lc.UserStatus | nil
function M.user_status()
    local query = [[
    query globalData {
      userStatus {
        userId
        is_signed_in: isSignedIn
        isMockUser
        is_premium: isPremium
        isVerified
        username
        activeSessionId
      }
    }
  ]]

    local ok, res = pcall(utils.query, query)
    if not ok then return end

    local status = res["userStatus"]
    config.authenticate(status)

    return res["userStatus"]
end

return M
