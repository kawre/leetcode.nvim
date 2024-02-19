---@class lc.plugins.cn
local cn = {}

cn.opts = {
    lazy = true,
}

function cn.load()
    local config = require("leetcode.config")

    config.translator = config.user.cn.translator
    config.domain = "cn"
    config.is_cn = true
    config.sessions.default = "匿名"

    require("leetcode-plugins.cn.urls")
    require("leetcode-plugins.cn.queries")
    require("leetcode-plugins.cn.api")
    require("leetcode-plugins.cn.normalizer")
end

return cn
