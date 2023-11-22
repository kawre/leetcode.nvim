local Page = require("leetcode-menu.page")

local Header = require("leetcode-menu.components.header")
local Buttons = require("leetcode-menu.components.buttons")

local Button = require("leetcode-ui.lines.button")
local Title = require("leetcode-menu.components.title")

local exit = Button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

local page = Page()

page:insert(Header())

page:insert(Title({}, "Loading..."))

page:insert(Buttons({
    exit,
}))

return page
