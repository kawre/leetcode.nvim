local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")

local Indent = require("leetcode-ui.text.indent")
local Line = require("nui.line")

local u = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@class lc.ui.Tag.ol : lc.ui.Tag
---@field indent integer
---@field i integer
local Ol = Tag:extend("LeetTagOl")

function Ol:contents()
    local items = Ol.super.contents(self)

    for _, value in ipairs(items) do
        for _, line in ipairs(Lines.contents(value)) do
            local texts = line:contents()

            line = Line(texts)
            if not vim.tbl_isempty(texts) then --
                local indent = Indent(self.indent, "", "leetcode_list")
                table.insert(texts, 1, indent)

                -- if u.is_instance(texts[1], Indent) then
                --     texts[1] = indent
                -- else
                -- end

                -- self.i = self.i + 1
            end

            line = Line(texts)
        end
    end

    return items
end

function Ol:init(text, opts, node, tags) --
    Ol.super.init(self, text, opts, node, tags)

    -- self.indent = vim.fn.count(self.tags, "ol") or 0
    self.i = 1
end

---@type fun(): lc.ui.Tag.pre
local LeetTagOl = Ol

return LeetTagOl
