local Lines = require("leetcode-ui.lines")

---@class lc.ui.Padding: lc.ui.Lines
---@field times integer
local Padding = Lines:extend("LeetPadding")

---@param int integer
---
---@return lc.ui.Lines
function Padding:init(int)
    Padding.super.init(self)

    for _ = 1, int do
        self:append(""):endl()
    end
end

---@type fun(int: integer): lc.ui.Padding
local LeetPadding = Padding

return LeetPadding
