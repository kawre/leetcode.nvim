local Cookie = require("leetcode.cache.cookie")
local config = require("leetcode.config")

local headers = {}

function headers.get()
    local cookie = Cookie.get()

    return vim.tbl_extend("force", {
        ["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0",
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
