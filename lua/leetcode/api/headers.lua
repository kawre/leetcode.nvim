local Cookie = require("leetcode.cache.cookie")
local config = require("leetcode.config")

local headers = {}

function headers.get()
    local cookie = Cookie.get()

    return vim.tbl_extend("force", {
        ["Referer"] = config.domain,
        ["Origin"] = config.domain .. "/",
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Host"] = ("leetcode.%s"):format(config.user.domain),
    }, cookie and {
        ["Cookie"] = cookie.str,
        ["x-csrftoken"] = cookie.csrftoken,
    } or {})
end

return headers
