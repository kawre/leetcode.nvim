local Group = require("leetcode-ui.group")

---@class lc.ui.Buttons : lc.ui.Group
local Buttons = Group:extend("LeetButtons")

function Buttons:init(buttons, opts) --
    Buttons.super.init(self, buttons or {}, opts or {})
end

---@type fun(buttons?: lc.ui.Button[], opts?: table): lc.ui.Buttons
local LeetButtons = Buttons

return LeetButtons
