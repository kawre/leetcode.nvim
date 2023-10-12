local utils = require("leetcode.api.utils")
local config = require("leetcode.config")

---@class lc.AuthApi
local M = {}

local function update_auth(data)
    local auth = data.userStatus

    assert(auth.is_signed_in, "Sign-in failed")
    assert(auth.is_verified, "Please verify your email address in order to use your account.")

    config.auth = auth
    return config.auth
end

local usr_fields = [[
    id: userId
    is_signed_in: isSignedIn
    is_premium: isPremium
    name: username
    is_verified: isVerified
]]

---@return lc.UserAuth
function M.user()
    local query = string.format(
        [[
            query globalData {
              userStatus { %s }
            }
        ]],
        usr_fields
    )

    local ok, res = pcall(utils.query, query)
    if not ok then return {} end

    return update_auth(res.body.data)
end

function M._user(cb)
    local query = string.format(
        [[
            query globalData {
              userStatus { %s }
            }
        ]],
        usr_fields
    )

    utils._query(query, {}, function(res)
        local data = res.body.data
        local ok, auth = pcall(update_auth, data)
        cb(auth, not ok and auth or nil)
    end)
end

return M
