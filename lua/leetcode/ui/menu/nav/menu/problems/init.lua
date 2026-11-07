local m = require("markup")

local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")
local BackButton = require("leetcode.ui.menu.button.back")

return m.component(function()
    local cmd = require("leetcode.cmd")

    return Buttons({
        Button({
            icon = "",
            title = "List",
            desc = "Every problem, with filters",
            lhs = "p",
            nested = true,
            on_submit = function()
                require("leetcode.ui.browser").open(require("leetcode.cache.problems").get())
            end,
        }),
        Button({
            icon = "",
            title = "Random",
            desc = "Pick one for me",
            lhs = "s",
            nested = true,
            on_submit = cmd.random_question,
        }),
        Button({
            icon = "󰃭",
            title = "Daily",
            desc = "Today's challenge",
            lhs = "i",
            nested = true,
            on_submit = cmd.qot,
        }),
        BackButton({ page = "menu" }),
    })
end)
