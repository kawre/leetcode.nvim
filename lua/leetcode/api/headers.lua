local log = require("leetcode.logger")
local cookie = require("leetcode.cache.cookie")

local headers = {}

headers.get = function()
    local c = cookie.get()

    return {
        ["Referer"] = "https://leetcode.com/",
        ["Origin"] = "https://leetcode.com",
        ["Cookie"] = c and string.format(
            "LEETCODE_SESSION=%s;csrftoken=%s",
            c.leetcode_session,
            c.csrftoken
        ) or "",
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["X-Csrftoken"] = c and c.csrftoken or nil,
    }
end

return headers
