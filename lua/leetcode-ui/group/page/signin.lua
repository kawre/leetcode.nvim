local cmd = require("leetcode.cmd")
local config = require("leetcode.config")

local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Group = require("leetcode-ui.group")
local Button = require("leetcode-ui.lines.button.menu")
local ExitButton = require("leetcode-ui.lines.button.menu.exit")

local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)

page:insert(Title({}, "Sign in"))

local problems = Button("Sign in (By Cookie)", {
    icon = "󱛖",
    sc = "s",
    on_press = cmd.cookie_prompt,
})

local exit = ExitButton()

page:insert(Buttons({
    problems,
    exit,
}))

local footer = Group({}, {
    hl = "Number",
})
footer:append("leetcode." .. config.domain)
page:insert(footer)

return page
