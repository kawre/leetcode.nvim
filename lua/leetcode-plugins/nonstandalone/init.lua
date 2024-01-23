---@class lc.plugins.nonstandalone
local nonstandalone = {}

function nonstandalone.load() --
    require("leetcode-plugins.nonstandalone.exit")
    require("leetcode-plugins.nonstandalone.leetcode")
    require("leetcode-plugins.nonstandalone.command")
end

return nonstandalone
