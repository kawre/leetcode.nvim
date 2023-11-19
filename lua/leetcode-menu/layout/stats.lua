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

local calendar = Calendar:init()
local solved = Solved:init()

local group = Group:init({ solved, calendar }, {
    spacing = 2,
    padding = {
        top = 4,
        bot = 2,
    },
})

local skills = not config.is_cn
        and Button:init({ icon = "", src = "Skills" }, "s", cmd.ui_skills)
    or nil

local languages = Button:init({ icon = "", src = "Languages" }, "l", cmd.ui_languages)

local update = Button:init({ icon = "", src = "Update" }, "u", function() calendar:update() end)

local back = Button:init(
    { icon = "", src = "Back" },
    "q",
    function() cmd.menu_layout("menu") end
)

return Layout:init({
    group,

    Title:init({ "Menu" }, "Statistics"),

    Buttons:init({
        skills,
        languages,
        update,
        back,
    }),

    Footer:init(),
})
