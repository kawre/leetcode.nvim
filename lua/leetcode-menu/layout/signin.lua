local Layout = require("leetcode-ui.layout")
local Title = require("leetcode-menu.components.title")
local cmd = require("leetcode.command")
local Buttons = require("leetcode-menu.components.buttons")

local button = require("leetcode-ui.component.button")

local problems =
    button:init({ icon = "󱛖", src = "Sign in (By Cookie)" }, "s", cmd.cookie_prompt(), false)

local exit = button:init({ src = "Exit", icon = "󰩈" }, "q", function() vim.cmd.quitall() end)

local buttons = Buttons:init({
    components = {
        problems,
        exit,
    },
})

local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

return Layout:init({
    components = {
        Header:init(),

        Title:init({}, "Sign in"),
        --
        buttons,
        --
        Footer:init(),
    },
    opts = {
        margin = 5,
    },
})
