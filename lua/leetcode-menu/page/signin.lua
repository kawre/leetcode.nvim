local Page = require("leetcode-menu.page")
local Title = require("leetcode-menu.components.title")
local cmd = require("leetcode.command")
local Buttons = require("leetcode-menu.components.buttons")

local Button = require("leetcode-ui.lines.button")

local problems =
    Button({ icon = "󱛖", src = "Sign in (By Cookie)" }, "s", cmd.cookie_prompt, false)

local exit = Button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

local buttons = Buttons({
    problems,
    exit,
})

local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

return Page({
    Header(),

    Title({}, "Sign in"),

    buttons,

    Footer(),
})
