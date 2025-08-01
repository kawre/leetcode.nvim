local m = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")
local config = require("leetcode.config")
local log = require("leetcode.logger")

local cmd = require("leetcode.cmd")

return m.component(function()
    return Buttons({
        not config.is_cn and Button({
            title = "Skills",
            icon = "",
            lhs = "s",
            on_submit = cmd.ui_skills,
        }),
        Button({
            icon = "",
            title = "Languages",
            lhs = "l",
            on_submit = cmd.ui_languages,
        }),
        Button({
            icon = "",
            title = "Update",
            lhs = "u",
            on_submit = function() end,
        }),
        BackButton({ page = "menu" }),
    })
end)
