local Layout = require("leetcode-ui.layout")

local Header = require("leetcode-menu.components.header")
local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.component.button")
local Title = require("leetcode-menu.components.title")

local title = Title:init({}, "Loading...")

local exit = Button:init({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

return Layout:init({
    Header:init(),

    title,

    Buttons:init({
        exit,
    }),
})
