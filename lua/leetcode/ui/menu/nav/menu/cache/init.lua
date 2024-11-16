local markup = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")

return markup.Component(function()
    local cmd = require("leetcode.command")

    return Buttons({
        Button({
            icon = "󱘴",
            title = "Update",
            key = "u",
            on_submit = cmd.cache_update,
        }),
        BackButton("menu"),
    })
end)
