---@class lc.plugins.non_standalone
local non_standalone = {}

non_standalone.opts = {
    lazy = false,
}

function non_standalone.load() --
    require("leetcode-plugins.non_standalone.leetcode")
end

return non_standalone
