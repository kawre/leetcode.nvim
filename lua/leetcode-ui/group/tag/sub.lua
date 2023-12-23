local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sub : lc.ui.Tag
local Sub = Tag:extend("LeetTagSub")

function Sub:contents()
    local Group = require("leetcode-ui.group")
    local grp = Group()

    grp:append("_", "leetcode_alt")
    grp:append(self:content(), "Number")

    return grp:contents()
end

---@type fun(): lc.ui.Tag.sub
local LeetTagSub = Sub

return LeetTagSub
