local Solved = require("leetcode-ui.lines.solved")
local Calendar = require("leetcode-ui.lines.calendar")
local Group = require("leetcode-ui.group")
local Footer = require("leetcode-ui.lines.footer")
local Page = require("leetcode-ui.group.page")
local Buttons = require("leetcode-ui.group.buttons")
local Button = require("leetcode-ui.lines.button")
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

local buttons = Buttons()

local skills = Button({ icon = "", src = "Skills" }, "s", cmd.ui_skills)
if not config.is_cn then buttons:insert(skills) end

local languages = Button({ icon = "", src = "Languages" }, "l", cmd.ui_languages)
buttons:insert(languages)

local update = Button({ icon = "", src = "Update" }, "u", function() calendar:update() end)
buttons:insert(update)

local back = Button({ icon = "", src = "Back" }, "q", function() cmd.menu_layout("menu") end)
buttons:insert(back)

page:insert(buttons)

page:insert(Footer())

return page
