local cmd = require("leetcode.command")
local Solved = require("leetcode-menu.components.solved")
local Calendar = require("leetcode-menu.components.calendar")
local Group = require("leetcode-ui.component.group")
local Footer = require("leetcode-menu.components.footer")
local config = require("leetcode.config")

local Layout = require("leetcode-ui.layout")

local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.component.button")
local Title = require("leetcode-menu.components.title")

local calendar = Calendar()
local solved = Solved()

local group = Group({
    spacing = 2,
    padding = {
        top = 4,
        bot = 2,
    },
})

group:append(calendar)
group:append(solved)

local skills = not config.is_cn and Button({ icon = "", src = "Skills" }, "s", cmd.ui_skills)
    or nil

local languages = Button({ icon = "", src = "Languages" }, "l", cmd.ui_languages)

local update = Button({ icon = "", src = "Update" }, "u", function() calendar:update() end)

local back = Button({ icon = "", src = "Back" }, "q", function() cmd.menu_layout("menu") end)

return Layout({
    group,

    Title({ "Menu" }, "Statistics"),

    Buttons({
        skills,
        languages,
        update,
        back,
    }),

    Footer(),
})
