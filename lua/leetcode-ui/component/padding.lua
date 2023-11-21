local Lines = require("leetcode-ui.component.text")
local NuiText = require("nui.text")

---@class lc-ui.Padding: lc-ui.Text
local Padding = Lines:extend("LeetPadding")

-- function Padding:content() return "" end

-- function Padding:append(_, _) return self end

---@param int integer
---
---@return lc-ui.Text
function Padding:init(int)
    Padding.super.init(self, {})

    for _ = 1, int, 1 do
        self:append(""):endl()
    end
end

---@type fun(int: integer): lc-ui.Padding
local LeetPadding = Padding

return LeetPadding
