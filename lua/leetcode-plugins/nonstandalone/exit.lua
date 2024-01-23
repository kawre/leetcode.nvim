local leetcode = require("leetcode")

local MenuExitButton = require("leetcode-ui.lines.button.menu.exit")

function MenuExitButton:init()
    MenuExitButton.super.init(self, "Exit", {
        icon = "󰩈",
        sc = "q",
        on_press = leetcode.stop,
    })
end
