local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sup : lc.ui.Tag
local Sup = Tag:extend("LeetTagSup")

function Sup:contents()
    local Group = require("leetcode-ui.group")
    local grp = Group()

    grp:append("^", "leetcode_alt")
    grp:append(self:content(), "Number")

    return grp:contents()
end

---@type fun(): lc.ui.Tag.sup
local LeetTagSup = Sup

return LeetTagSup
