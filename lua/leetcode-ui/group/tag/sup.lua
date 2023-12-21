local Tag = require("leetcode-ui.group.tag")
local Lines = require("leetcode-ui.lines")
local Line = require("nui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sup : lc.ui.Tag
local Sup = Tag:extend("LeetTagSup")

function Sup:contents()
    local items = Sup.super.contents(self)

    local c = vim.fn.count(self.tags, "ul")
    local indent = ("\t"):rep(c or 1)
    for _, value in ipairs(items) do
        local indent = Line():append(indent .. "* ", "leetcode_list")

        for _, line in ipairs(Lines.contents(value)) do
            table.insert(line._texts, 1, indent)
        end
    end

    return items
end

-- function Ul:init(opts, node)
--     opts = vim.tbl_deep_extend("force", opts or {}, { spacing = 1 })
--     Ul.super.init(self, opts, node)
-- end

---@type fun(): lc.ui.Tag.pre
local LeetTagSup = Sup

return LeetTagSup
