local markup = require("markup")
local log = require("leetcode.logger")

local Buttons = require("leetcode.ui.menu.buttons")
local Button = require("leetcode.ui.menu.button")

return markup.Component(function()
    return markup.vflex({
        width = 50,
        Buttons({
            Button({
                icon = "1",
                -- icon = "",
                title = "Problems",
                key = "p",
                nested = true,
                page = "menu.problems",
            }),
            Button({
                icon = "2",
                -- icon = "",
                title = "Statistics",
                key = "s",
                nested = true,
                page = "menu.statistics",
            }),
            Button({
                icon = "3",
                -- icon = "󰆘",
                title = "Cookie",
                key = "i",
                nested = true,
                page = "menu.cookie",
            }),
            Button({
                icon = "4",
                -- icon = "",
                title = "Cache",
                key = "c",
                nested = true,
                page = "menu.cache",
            }),
            Button({
                icon = "4",
                -- icon = "󰩈",
                title = "Exit",
                key = "qa",
                on_submit = function()
                    require("leetcode").stop()
                end,
            }),
        }),
    })
end)
