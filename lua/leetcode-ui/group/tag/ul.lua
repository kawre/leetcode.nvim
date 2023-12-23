local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Text = require("nui.text")

---@class lc.ui.Tag.ul : lc.ui.Tag
---@field indent string
local Ul = Tag:extend("LeetTagUl")

function Ul:contents()
    local items = Ul.super.contents(self)

    for _, value in ipairs(items) do
        for _, line in ipairs(Lines.contents(value)) do
            if not vim.tbl_isempty(line._texts) then
                local pre = Text("\t", "leetcode_list")
                table.insert(line._texts, 1, pre)
            end
        end
    end

    return items
end

---@type fun(): lc.ui.Tag.pre
local LeetTagUl = Ul

return LeetTagUl
