local Page = require("leetcode-menu.page")
local Title = require("leetcode-menu.components.title")
local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.lines.button")
local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

local cmd = require("leetcode.command")

local page = Page()

page:insert(Header())

page:insert(Title({}, "Sign in"))

local problems =
    Button({ icon = "󱛖", src = "Sign in (By Cookie)" }, "s", cmd.cookie_prompt, false)
local exit = Button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

page:insert(Buttons({
    problems,
    exit,
}))

page:insert(Footer())

return page
