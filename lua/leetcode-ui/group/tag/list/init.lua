local Tag = require("leetcode-ui.group.tag")

---@class lc.ui.Tag.List : lc.ui.Tag
---@field indent integer
local List = Tag:extend("LeetTagList")

function List:contents()
    local items = List.super.contents(self)

    for _, item in ipairs(items) do
        self:add_indent(item)
    end

    return items
end

---@type fun(): lc.ui.Tag.List
local LeetTagList = List

return LeetTagList
