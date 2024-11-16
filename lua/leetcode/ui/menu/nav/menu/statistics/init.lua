local markup = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")
local config = require("leetcode.config")

return markup.Component(function()
    local cmd = require("leetcode.command")

    local buttons = {
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
    }

    if not config.is_cn then
        local skills = Button({
            title = "Skills",
            icon = "",
            key = "s",
            on_submit = cmd.ui_skills,
        })
        table.insert(buttons, 1, skills)
    end

    return Buttons(buttons)
end)
