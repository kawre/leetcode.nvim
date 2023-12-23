local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.img : lc.ui.Tag
local Img = Tag:extend("LeetTagImg")

function Img:contents()
    -- local items = Img.super.contents(self)
    -- --
    -- -- local c = vim.fn.count(self.tags, "ul")
    -- -- local indent = ("\t"):rep(c)
    -- --
    -- -- for _, value in ipairs(items) do
    -- --     for _, line in ipairs(Lines.contents(value)) do
    -- --         local pre = Line():append(indent .. "* ", "leetcode_list")
    -- --         if not vim.tbl_isempty(line._texts) then table.insert(line._texts, 1, pre) end
    -- --     end
    -- -- end
    --
    -- -- table.insert(items, 1, Line())
    -- -- table.insert(items, Line())

    local Group = require("leetcode-ui.group")
    local grp = Group()

    grp:append("[", "leetcode_alt")
    grp:append(self:content(), "leetcode_ref")
    grp:append("]", "leetcode_alt")
    grp:append("(", "leetcode_alt")
    grp:append("fasdfasdjfk", "leetcode_link")
    grp:append(")", "leetcode_alt")

    return grp:contents()
end

---@type fun(): lc.ui.Tag.pre
local LeetTagImg = Img

return LeetTagImg
