local log = require("leetcode.logger")

local M = {}

M.get = function()
    local cookie = require("leetcode.cache.cookie").read()
    -- log.inspect(cookie or {})

    return {
        ["Referer"] = "https://leetcode.com/problems/two-sum/",
        ["Origin"] = "https://leetcode.com",
        ["Cookie"] = cookie and string.format(
            "LEETCODE_SESSION=%s;csrftoken=%s",
            cookie.leetcode_session,
            cookie.csrftoken
        ) or "",
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["x-csrftoken"] = cookie and cookie.csrftoken or nil,
    }
end

return M
