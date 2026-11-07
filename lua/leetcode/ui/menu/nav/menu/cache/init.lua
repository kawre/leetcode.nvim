local m = require("markup")
local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")

return m.component(function()
    local cmd = require("leetcode.cmd")

    return Buttons({
        Button({
            icon = "󱘴",
            title = "Update",
            desc = "Fetch the problem list again",
            lhs = "u",
            on_submit = cmd.cache_update,
        }),
        BackButton({ page = "menu" }),
    })
end)
