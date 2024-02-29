local cmd = require("leetcode.command")
local config = require("leetcode.config")

local Solved = require("leetcode-ui.lines.solved")
local Calendar = require("leetcode-ui.lines.calendar")
local Group = require("leetcode-ui.group")
local Page = require("leetcode-ui.group.page")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Title = require("leetcode-ui.lines.title")

local footer = require("leetcode-ui.lines.footer")

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

local buttons = Buttons({})

local skills = Button("Skills", {
    icon = "",
    sc = "s",
    on_press = cmd.ui_skills,
})
if not config.is_cn then
    buttons:insert(skills)
end

local languages = Button("Languages", {
    icon = "",
    sc = "l",
    on_press = cmd.ui_languages,
})
buttons:insert(languages)

local update = Button("Update", {
    icon = "",
    sc = "u",
    on_press = function()
        calendar:update()
        solved:update()
        config.stats.update()
    end,
})
buttons:insert(update)

local back = BackButton("menu")
buttons:insert(back)

page:insert(buttons)

page:insert(footer)

return page
