local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Line = require("nui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.pre : lc.ui.Tag
local Pre = Tag:extend("LeetTagPre")

function Pre:contents()
    local items = Pre.super.contents(self)

    for _, item in ipairs(items) do
        self:add_indent(item, "\t▎\t")
    end

    return items
end

---@type fun(): lc.ui.Tag.pre
local LeetTagPre = Pre

return LeetTagPre
