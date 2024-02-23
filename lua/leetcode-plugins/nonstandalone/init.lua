---@class lc.plugins.nonstandalone
local nonstandalone = {}

nonstandalone.opts = {
    lazy = false,
}

function nonstandalone.load()
    require("leetcode-plugins.nonstandalone.leetcode")
    require("leetcode-plugins.nonstandalone.command")
end

return nonstandalone
