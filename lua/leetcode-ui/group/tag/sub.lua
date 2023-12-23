local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sub : lc.ui.Tag
local Sub = Tag:extend("LeetTagSub")

function Sub:parse_node()
    self:append("_")

    Sub.super.parse_node(self)
end

---@type fun(): lc.ui.Tag.sub
local LeetTagSub = Sub

return LeetTagSub
