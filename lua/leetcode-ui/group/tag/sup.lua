local Tag = require("leetcode-ui.group.tag")
local Line = require("leetcode-ui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sup : lc.ui.Tag
local Sup = Tag:extend("LeetTagSup")

function Sup:parse_node()
    self:append("^")

    Sup.super.parse_node(self)
end

---@type fun(): lc.ui.Tag.sup
local LeetTagSup = Sup

return LeetTagSup
