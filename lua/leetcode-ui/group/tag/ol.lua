local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Line = require("nui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.ol : lc.ui.Tag
local Ol = Tag:extend("LeetTagUl")

function Ol:contents()
    local items = Ol.super.contents(self)

    for _, value in ipairs(items) do
        for i, line in ipairs(Lines.contents(value)) do
            local indent = Line():append(("\t%d. "):format(i), "leetcode_list")
            table.insert(line._texts, 1, indent)
        end
    end

    return items
end

---@type fun(): lc.ui.Tag.pre
local LeetTagUl = Ol

return LeetTagUl
