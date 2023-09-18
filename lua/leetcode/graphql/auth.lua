local gql = require("leetcode.graphql.utils")

---@class lc.AuthApi
local M = {}

---@return table | nil
function M.user_status()
  local query = [[
    query globalData {
      userStatus {
        userId
        isSignedIn
        isMockUser
        isPremium
        isVerified
        username
        isTranslator
        activeSessionId
        checkedInToday
      }
    }
  ]]

  local ok, res = pcall(gql.query, query)
  if not ok then return end

  return res["userStatus"]
end

return M
