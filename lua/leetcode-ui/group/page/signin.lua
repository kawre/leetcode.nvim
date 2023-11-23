local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons")
local Button = require("leetcode-ui.lines.button")
local Header = require("leetcode-ui.lines.menu-header")
local Footer = require("leetcode-ui.lines.footer")

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
