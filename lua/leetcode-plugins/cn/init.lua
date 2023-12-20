---@class lc.plugins.cn
local cn = {}

function cn.load()
    local config = require("leetcode.config")
    config.domain = "cn"
    config.is_cn = true

    require("leetcode-plugins.cn.urls")
    require("leetcode-plugins.cn.queries")
    require("leetcode-plugins.cn.api")
end

return cn
