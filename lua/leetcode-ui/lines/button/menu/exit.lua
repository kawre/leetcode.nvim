local MenuButton = require("leetcode-ui.lines.button.menu")

---@class lc.ui.Button.Menu.Exit : lc.ui.Button.Menu
local MenuExitButton = MenuButton:extend("LeetMenuExitButton")

---@param page lc-menu.page
function MenuExitButton:init()
    MenuExitButton.super.init(self, "Exit", {
        icon = "󰩈",
        sc = "q",
        on_press = function() vim.cmd.quitall() end,
    })
end

---@type fun(): lc.ui.Button.Menu.Back
local LeetMenuExitButton = MenuExitButton

return LeetMenuExitButton
