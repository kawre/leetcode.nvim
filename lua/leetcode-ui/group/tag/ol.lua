local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Line = require("nui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.ol : lc.ui.Tag
---@field indent string
local Ol = Tag:extend("LeetTagOl")

function Ol:contents()
    local items = Ol.super.contents(self)

    for _, value in ipairs(items) do
        for i, line in ipairs(Lines.contents(value)) do
            local pre = Line():append(self.indent .. i .. " ", "leetcode_list")
            if not vim.tbl_isempty(line._texts) then table.insert(line._texts, 1, pre) end
        end
    end

    return items
end

function Ol:init(text, opts, node, tags) --
    Ol.super.init(self, text, opts, node, tags)

    local c = vim.fn.count(self.tags, "ol")
    self.indent = ("\t"):rep(c or 0)
end

---@type fun(): lc.ui.Tag.pre
local LeetTagOl = Ol

return LeetTagOl
