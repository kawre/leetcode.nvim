local MenuButton = require("leetcode-ui.lines.button.menu")
local leetcode = require("leetcode")

---@class lc.ui.Button.Menu.Exit : lc.ui.Button.Menu
local MenuExitButton = MenuButton:extend("LeetMenuExitButton")

---@param page lc-menu.page
function MenuExitButton:init()
    MenuExitButton.super.init(self, "Exit", {
        icon = "󰩈",
        sc = "qa",
        on_press = leetcode.stop,
    })
end

---@type fun(): lc.ui.Button.Menu.Back
local LeetMenuExitButton = MenuExitButton

return LeetMenuExitButton
