local markup = require("markup")

local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")

return markup.Component(function()
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
            key = "q",
            on_submit = function()
                require("leetcode").stop()
            end,
        }),
    })
end)
