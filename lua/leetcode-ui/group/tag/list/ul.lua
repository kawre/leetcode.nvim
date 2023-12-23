local List = require("leetcode-ui.group.tag.list")

local log = require("leetcode.logger")

---@class lc.ui.Tag.ul : lc.ui.Tag.List
local Ul = List:extend("LeetTagUl")

function Ul:init(text, opts, node, tags)
    log.info("ul")

    Ul.super.init(self, text, opts, node, tags)
end

---@type fun(): lc.ui.Tag.ul
local LeetTagUl = Ul

return LeetTagUl
