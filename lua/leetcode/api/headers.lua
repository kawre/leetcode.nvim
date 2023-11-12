local cookie = require("leetcode.cache.cookie")

local headers = {}

headers.get = function()
    local c = cookie.get()

    return {
        ["Referer"] = "https://leetcode.com/",
        ["Origin"] = "https://leetcode.com",
        ["Host"] = "leetcode.com",
        ["Cookie"] = cookie.to_str(),
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["x-csrftoken"] = c and c.csrftoken or nil,
    }
end

return headers
