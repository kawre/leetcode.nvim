local cookie = require("leetcode.cache.cookie")
local config = require("leetcode.config")

local headers = {}

headers.get = function()
    local c = cookie.get()

    return {
        ["Referer"] = config.domain,
        ["Origin"] = config.domain .. "/",
        ["Host"] = ("leetcode.%s"):format(config.user.domain),
        ["Cookie"] = cookie.to_str(),
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["x-csrftoken"] = c and c.csrftoken or nil,
    }
end

return headers
