local Layout = require("leetcode-ui.layout")

local Header = require("leetcode-menu.components.header")
local Buttons = require("leetcode-menu.components.buttons")
local button = require("leetcode-ui.component.button")
local Title = require("leetcode-menu.components.title")

local title = Title:init({}, "Loading...")

local exit = button:init({ src = "Exit", icon = "󰩈" }, "q", function() vim.cmd.quitall() end)

return Layout:init({
    components = {
        Header:init(),

        title,

        Buttons:init({
            components = {
                exit,
            },
        }),
    },
})
