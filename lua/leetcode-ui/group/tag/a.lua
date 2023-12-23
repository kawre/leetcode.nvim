local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.a : lc.ui.Tag
local A = Tag:extend("LeetTagA")

function A:contents()
    local el = self:get_el_data(self.node)

    if self:content() == el.attrs.href then
        return A.super.contents(self)
    else
        local Group = require("leetcode-ui.group")
        local grp = Group()

        grp:append("[", "leetcode_alt")
        grp:append(self:content(), "leetcode_ref")
        grp:append("]", "leetcode_alt")
        grp:append("(", "leetcode_alt")
        grp:append(el.attrs.href or "", "leetcode_link")
        grp:append(")", "leetcode_alt")

        return grp:contents()
    end
end

---@type fun(): lc.ui.Tag.pre
local LeetTagA = A

return LeetTagA
