local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Line = require("nui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.ul : lc.ui.Tag
---@field indent string
local Ul = Tag:extend("LeetTagUl")

function Ul:contents()
    local items = Ul.super.contents(self)

    for _, value in ipairs(items) do
        for _, line in ipairs(Lines.contents(value)) do
            local pre = Line():append(self.indent .. "* ", "leetcode_list")
            if not vim.tbl_isempty(line._texts) then table.insert(line._texts, 1, pre) end
        end
    end

    return items
end

function Ul:init(text, opts, node, tags)
    -- opts = vim.tbl_deep_extend("force", opts or {}, { spacing = 1 })
    Ul.super.init(self, text, opts, node, tags)

    local c = vim.fn.count(self.tags, "ul")
    self.indent = ("\t"):rep(c or 0)
end

---@type fun(): lc.ui.Tag.pre
local LeetTagUl = Ul

return LeetTagUl
