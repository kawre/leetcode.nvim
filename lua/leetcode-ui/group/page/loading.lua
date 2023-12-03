local Page = require("leetcode-ui.group.page")

local Header = require("leetcode-ui.lines.menu-header")
local Buttons = require("leetcode-ui.group.buttons.menu")

local ExitButton = require("leetcode-ui.lines.button.menu.exit")
local Title = require("leetcode-ui.lines.title")

local page = Page()

page:insert(Header())

page:insert(Title({}, "Loading..."))

local exit = ExitButton()

page:insert(Buttons({
    exit,
}))

return page
