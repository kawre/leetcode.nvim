---@lc.plugins.cn
local cn = {}

function cn.load()
    require("leetcode-plugins.cn.urls")
    require("leetcode-plugins.cn.queries")
    require("leetcode-plugins.cn.api")
end

return cn
