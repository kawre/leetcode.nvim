local Solved = require("leetcode-ui.lines.solved")
local Calendar = require("leetcode-ui.lines.calendar")
local Group = require("leetcode-ui.group")
local Footer = require("leetcode-ui.lines.footer")
local Page = require("leetcode-ui.group.page")
local Buttons = require("leetcode-ui.group.buttons")
local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Title = require("leetcode-ui.lines.title")

local cmd = require("leetcode.command")
local config = require("leetcode.config")

local page = Page()

local calendar = Calendar()
local solved = Solved()

local header = Group({}, {
    spacing = 2,
    margin = {
        bot = 2,
    },
})

header:insert(solved)
header:insert(calendar)

page:insert(header)

page:insert(Title({ "Menu" }, "Statistics"))

local skills = Button("Skills", {
    icon = "",
    sc = "s",
    on_press = cmd.ui_skills,
})

local languages = Button("Languages", {
    icon = "",
    sc = "l",
    on_press = cmd.ui_languages,
})

local update = Button("Update", {
    icon = "",
    sc = "u",
    on_press = function() calendar:update() end,
})

local back = BackButton("menu")

local buttons = Buttons({
    config.is_cn and nil or skills,
    languages,
    update,
    back,
})

page:insert(buttons)

page:insert(Footer())

return page
