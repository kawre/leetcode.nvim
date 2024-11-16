local markup = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")

return markup.Component(function()
    local cmd = require("leetcode.command")

    return Buttons({
        Button({
            icon = "󱛬",
            key = "u",
            title = "Update",
            on_press = cmd.cookie_prompt,
        }),
        Button({
            icon = "󱛪",
            key = "d",
            title = "Delete / Sign out",
            on_submit = cmd.sign_out,
        }),
        BackButton("menu"),
    })
end)
