local Group = require("leetcode-ui.group")

---@class lc.ui.Buttons.Menu : lc.ui.Group
local MenuButtons = Group:extend("LeetMenuButtons")

function MenuButtons:init(buttons, opts)
    opts = vim.tbl_deep_extend("force", {
        padding = {
            bot = 2,
        },
        spacing = 1,
    }, opts or {})

    MenuButtons.super.init(self, buttons or {}, opts)
end

---@type fun(buttons?: lc.ui.Button[], opts?: table): lc.ui.Buttons.Menu
local LeetMenuButtons = MenuButtons

return LeetMenuButtons
