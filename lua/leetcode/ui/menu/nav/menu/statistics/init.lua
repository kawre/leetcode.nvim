local m = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")
local config = require("leetcode.config")
local solved = require("leetcode.ui.menu.solved")

local cmd = require("leetcode.cmd")

return m.component(function()
    return Buttons({
        not config.is_cn and Button({
            title = "Skills",
            desc = "Solved by topic",
            icon = "",
            lhs = "s",
            on_submit = cmd.ui_skills,
        }),
        Button({
            icon = "",
            title = "Languages",
            desc = "Solved by language",
            lhs = "l",
            on_submit = cmd.ui_languages,
        }),
        Button({
            icon = "",
            title = "Update",
            desc = "Fetch the latest numbers",
            lhs = "u",
            on_submit = function()
                solved.update()
                Leet.menu.refresh()
            end,
        }),
        BackButton({ page = "menu" }),
    })
end)
