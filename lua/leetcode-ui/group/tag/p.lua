local Tag = require("leetcode-ui.group.tag")

---@class lc.ui.Tag.p : lc.ui.Tag
local P = Tag:extend("LeetTagP")

function P:init() --
    -- P.super.init(self, { hl = "leetcode_code" })
end

---@type fun(): lc.ui.Tag.p
local LeetTagP = P

return LeetTagP
