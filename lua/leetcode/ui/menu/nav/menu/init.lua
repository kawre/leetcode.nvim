local m = require("markup")
local log = require("leetcode.logger")

local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")

return m.component(function()
    return Buttons({
        Button({
            icon = "",
            title = "Problems",
            key = "p",
            nested = true,
            page = "menu.problems",
        }),
        Button({
            icon = "",
            title = "Statistics",
            key = "s",
            nested = true,
            page = "menu.statistics",
        }),
        Button({
            icon = "󰆘",
            title = "Cookie",
            key = "i",
            nested = true,
            page = "menu.cookie",
        }),
        Button({
            icon = "",
            title = "Cache",
            key = "c",
            nested = true,
            page = "menu.cache",
        }),
        Button({
            icon = "󰩈",
            title = "Exit",
            key = "qa",
            on_submit = function()
                require("leetcode").stop()
            end,
        }),
    })
end)
