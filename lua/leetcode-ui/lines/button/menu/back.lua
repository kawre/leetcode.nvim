local MenuButton = require("leetcode-ui.lines.button.menu")
local cmd = require("leetcode.command")

---@class lc.ui.Button.Menu.Back : lc.ui.Button.Menu
local MenuBackButton = MenuButton:extend("LeetMenuBackButton")

---@param page lc-menu.page
function MenuBackButton:init(page)
    MenuBackButton.super.init(self, "Back", {
        icon = "",
        sc = "q",
        on_press = function()
            cmd.set_menu_page(page)
        end,
    })
end

---@type fun(page: lc-menu.page): lc.ui.Button.Menu.Back
local LeetMenuBackButton = MenuBackButton

return LeetMenuBackButton
