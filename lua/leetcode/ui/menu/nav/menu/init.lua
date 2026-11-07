local m = require("markup")
local log = require("leetcode.logger")

local Buttons = require("leetcode.ui.menu.tiles")
local Button = require("leetcode.ui.menu.tile")

return m.component(function()
    return Buttons({
        Button({
            icon = "",
            title = "Problems",
            desc = "Browse, filter and search",
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
            title = "Cookie",
            desc = "Sign in again or sign out",
            lhs = "i",
            nested = true,
            page = "menu.cookie",
        }),
        Button({
            icon = "",
            title = "Cache",
            desc = "Refresh the problem list",
            lhs = "c",
            nested = true,
            page = "menu.cache",
        }),
        Button({
            icon = "󰩈",
            title = "Exit",
            desc = "Close leetcode.nvim",
            lhs = "qa",
            on_submit = function()
                require("leetcode").stop()
            end,
        }),
    })
end)
