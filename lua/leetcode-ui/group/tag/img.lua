local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.img : lc.ui.Tag
local Img = Tag:extend("LeetTagImg")

function Img:contents()
    local Group = require("leetcode-ui.group")
    local grp = Group()

    local el = self:get_el_data(self.node)

    grp:append("[", "leetcode_alt")
    grp:append(self:content(), "leetcode_ref")
    grp:append("]", "leetcode_alt")
    grp:append("(", "leetcode_alt")
    grp:append(el.attrs.src or "", "leetcode_link")
    grp:append(")", "leetcode_alt")

    return grp:contents()
end

---@type fun(): lc.ui.Tag.pre
local LeetTagImg = Img

return LeetTagImg
