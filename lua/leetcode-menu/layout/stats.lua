local cmd = require("leetcode.command")
local statistics = require("leetcode.api.statistics")
local Solved = require("leetcode-menu.components.solved")
local Calendar = require("leetcode-menu.components.calendar")
local Group = require("leetcode-ui.component.group")
local Footer = require("leetcode-menu.components.footer")
local Header = require("leetcode-menu.components.header")
local log = require("leetcode.logger")

local Layout = require("leetcode-ui.layout")

local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.component.button")
local Title = require("leetcode-menu.components.title")

local title = Title:init({ "Menu" }, "Statistics")

local skills = Button:init(
    { icon = "", src = "Skills" },
    "s",
    function() cmd.menu_layout("menu") end
)

local languages = Button:init(
    { icon = "", src = "Languages" },
    "l",
    function() cmd.menu_layout("menu") end
)

local back = Button:init(
    { icon = "", src = "Back" },
    "q",
    function() cmd.menu_layout("menu") end
)

local group = Group:init({ Header:init() })

statistics.solved(function(res)
    group:set_opts({
        spacing = 3,
        padding = {
            top = 3,
            bot = 3,
        },
    })

    group.components = { Solved:init(res), Calendar:init(res) }
    _Lc_Menu:draw()
end)

return Layout:init({
    group,

    title,

    Buttons:init({
        skills,
        languages,
        back,
    }),

    Footer:init(),
})
