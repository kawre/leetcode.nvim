local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Line = require("nui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.ul : lc.ui.Tag
local Ul = Tag:extend("LeetTagUl")

function Ul:contents()
    local items = Ul.super.contents(self)

    local c = vim.fn.count(self.tags, "ul")
    local indent = ("\t"):rep(c)
    local pre = Line():append(indent .. "* ", "leetcode_list")

    for _, value in ipairs(items) do
        for _, line in ipairs(Lines.contents(value)) do
            -- if c > 1 then table.remove(line._texts, 2) end
            table.insert(line._texts, 1, pre)
        end
    end

    return items
end

-- function Ul:init(opts, node)
--     opts = vim.tbl_deep_extend("force", opts or {}, { spacing = 1 })
--     Ul.super.init(self, opts, node)
-- end

---@type fun(): lc.ui.Tag.pre
local LeetTagUl = Ul

return LeetTagUl
