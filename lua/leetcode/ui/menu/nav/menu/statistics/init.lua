local markup = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")
local config = require("leetcode.config")
local log = require("leetcode.logger")

return markup.Component(function(self)
    local cmd = require("leetcode.command")

    return Buttons({
        markup.If(
            not self.state.expanded,
            Button({
                title = "Skills",
                icon = "",
                key = "s",
                on_submit = cmd.ui_skills,
            })
        ),
        Button({
            icon = "",
            title = "Languages",
            key = "l",
            on_submit = cmd.ui_languages,
        }),
        Button({
            icon = "",
            title = "Update",
            key = "u",
            on_submit = function() end,
        }),
        BackButton("menu"),
    })
end)
