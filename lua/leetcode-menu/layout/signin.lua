local Layout = require("leetcode-ui.layout")
local Title = require("leetcode-menu.components.title")
local cmd = require("leetcode.command")
local Buttons = require("leetcode-menu.components.buttons")

local button = require("leetcode-ui.group.button")

local problems =
    button({ icon = "󱛖", src = "Sign in (By Cookie)" }, "s", cmd.cookie_prompt, false)

local exit = button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

local buttons = Buttons({
    problems,
    exit,
})

local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

return Layout({
    Header(),

    Title({}, "Sign in"),

    buttons,

    Footer(),
}, {
    margin = 5,
})
