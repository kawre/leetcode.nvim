local Lines = require("leetcode-ui.component.text")

---@class lc-ui.Padding: lc-ui.Text
local Padding = Lines:extend("LeetPadding")

--------------------------------------------------------
--- Methods
--------------------------------------------------------

--------------------------------------------------------
--- Constructor
--------------------------------------------------------

---@param int integer
---
---@return lc-ui.Component
function Padding:init(int)
    Padding.super.init(self, {})

    for _ = 1, int, 1 do
        self:append(""):endl()
    end
end

---@type fun(int: integer): lc-ui.Padding
local LeetPadding = Padding

return LeetPadding
