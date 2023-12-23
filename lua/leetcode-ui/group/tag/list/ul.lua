local List = require("leetcode-ui.group.tag.list")

---@class lc.ui.Tag.ul : lc.ui.Tag.List
local Ul = List:extend("LeetTagUl")

---@type fun(): lc.ui.Tag.ul
local LeetTagUl = Ul

return LeetTagUl
