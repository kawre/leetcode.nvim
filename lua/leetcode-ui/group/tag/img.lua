local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.img : lc.ui.Tag
local Img = Tag:extend("LeetTagImg")

function Img:contents()
    local Group = require("leetcode-ui.group")
    local grp = Group()

    local alt = self.data.attrs.alt
    local link = (self.data.attrs.src or ""):gsub("：", ":")

    grp:append("![", "leetcode_alt")
    grp:append((alt and alt ~= "") and alt or "img", "leetcode_ref")
    grp:append("]", "leetcode_alt")
    grp:append("(", "leetcode_alt")
    grp:append(link, "leetcode_link")
    grp:append(")", "leetcode_alt")

    return grp:contents()
end

---@type fun(): lc.ui.Tag.pre
local LeetTagImg = Img

return LeetTagImg
