local api = require("leetcode.api")

local utils = {}

function utils.to_curl_headers()
    local t = {}

    for key, value in pairs(api.headers) do
        table.insert(t, "-H")
        table.insert(t, key .. ": " .. value)
    end

    return unpack(t)
end

return utils
