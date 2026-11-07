local m = require("markup")
local log = require("leetcode.logger")

local Buttons = require("leetcode.ui.menu.tiles")
local Button = require("leetcode.ui.menu.tile")

return m.component(function()
    return Buttons({
        Button({
            icon = "",
            title = "Problems",
            desc = "Browse, random, daily and recent",
            lhs = "p",
            nested = true,
            page = "menu.problems",
        }),
        Button({
            icon = "",
            title = "Statistics",
            desc = "Skills and languages",
            lhs = "s",
            nested = true,
            page = "menu.statistics",
        }),
        Button({
            icon = "󰆘",
            title = "Account",
            desc = "Change your cookie or sign out",
            lhs = "i",
            nested = true,
            page = "menu.cookie",
        }),
        Button({
            icon = "",
            title = "Refresh",

            desc = "Fetch the problem list again",
            lhs = "c",

            on_submit = function()

                require("leetcode.cmd").cache_update()

            end,
        }),
        Button({
            icon = "󰩈",
            title = "Quit",
            desc = "Close leetcode.nvim",
            lhs = "qa",
            on_submit = function()
                require("leetcode").stop()
            end,
        }),
    })
end)
