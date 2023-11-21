local Layout = require("leetcode-ui.layout")

local Header = require("leetcode-menu.components.header")
local Buttons = require("leetcode-menu.components.buttons")

local Button = require("leetcode-ui.component.button")
local Title = require("leetcode-menu.components.title")

local exit = Button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

return Layout({
    Header(),

    Title({}, "Loading..."),

    Buttons({
        exit,
    }),
})
