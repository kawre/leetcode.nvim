local markup = require("markup")

local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")

return markup.Component(function()
    local cmd = require("leetcode.command")

    return Buttons({
        Button({
            icon = "",
            title = "List",
            key = "p",
            nested = true,
            on_submit = cmd.problems,
        }),
        Button({
            icon = "",
            title = "Random",
            key = "s",
            nested = true,
            on_submit = cmd.random_question,
        }),
        Button({
            icon = "󰃭",
            title = "Daily",
            key = "i",
            nested = true,
            on_submit = cmd.qot,
        }),
        BackButton({ page = "menu" }),
    })
end)
