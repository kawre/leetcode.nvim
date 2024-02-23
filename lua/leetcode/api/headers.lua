local Cookie = require("leetcode.cache.cookie")
local config = require("leetcode.config")

local headers = {}

function headers.get()
    local cookie = Cookie.get()

    return vim.tbl_extend("force", {
        ["Referer"] = ("https://leetcode.%s"):format(config.domain),
        ["Origin"] = ("https://leetcode.%s/"):format(config.domain),
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Host"] = ("leetcode.%s"):format(config.domain),
        ["X-Requested-With"] = "XMLHttpRequest",
    }, cookie and {
        ["Cookie"] = cookie.str,
        ["x-csrftoken"] = cookie.csrftoken,
    } or {})
end

return headers
