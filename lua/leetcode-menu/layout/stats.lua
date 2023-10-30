local cmd = require("leetcode.command")
local Calendar = require("leetcode-menu.components.calendar")
local statistics = require("leetcode.api.statistics")
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

local Footer = require("leetcode-menu.components.footer")

statistics.solved(function(res)
    --
    log.info(res)
end)

return Layout:init({
    Calendar:init(),

    title,

    Buttons:init({
        skills,
        languages,
        back,
    }),

    Footer:init(),
})
