local Page = require("leetcode-ui.group.page")

local Header = require("leetcode-ui.lines.menu-header")
local Buttons = require("leetcode-ui.group.buttons")

local Button = require("leetcode-ui.lines.button")
local Title = require("leetcode-ui.lines.title")

local exit = Button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

local page = Page()

page:insert(Header())

page:insert(Title({}, "Loading..."))

page:insert(Buttons({
    exit,
}))

return page
