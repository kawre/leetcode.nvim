local markup = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")

return markup.component(function()
    local cmd = require("leetcode.cmd")

    return Buttons({
        Button({
            icon = "󱛬",
            lhs = "u",
            title = "Update",
            on_press = cmd.cookie_prompt,
        }),
        Button({
            icon = "󱛪",
            lhs = "d",
            title = "Delete / Sign out",
            on_submit = cmd.sign_out,
        }),
        BackButton({ page = "menu" }),
    })
end)
