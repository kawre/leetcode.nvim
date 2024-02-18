local Page = require("leetcode-ui.group.page")
local Buttons = require("leetcode-ui.group.buttons.menu")
local ExitButton = require("leetcode-ui.lines.button.menu.exit")
local Title = require("leetcode-ui.lines.title")

local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)

page:insert(Title({}, "Loading..."))

local exit = ExitButton()

page:insert(Buttons({
    exit,
}))

return page
