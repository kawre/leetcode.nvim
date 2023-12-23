local List = require("leetcode-ui.group.tag.list")

local log = require("leetcode.logger")

---@class lc.ui.Tag.ol : lc.ui.Tag.List
---@field order integer
local Ol = List:extend("LeetTagOl")

function Ol:init(text, opts, node, tags)
    self.order = 1
    log.info("ol")

    Ol.super.init(self, text, opts, node, tags)
end

---@type fun(): lc.ui.Tag.ol
local LeetTagOl = Ol

return LeetTagOl
