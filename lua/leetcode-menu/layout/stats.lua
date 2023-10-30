local cmd = require("leetcode.command")
local statistics = require("leetcode.api.statistics")
local Solved = require("leetcode-menu.components.solved")
local Calendar = require("leetcode-menu.components.calendar")
local Group = require("leetcode-ui.component.group")
local Footer = require("leetcode-menu.components.footer")
local Header = require("leetcode-menu.components.header")
local Spinner = require("leetcode.logger.spinner")
local log = require("leetcode.logger")

local Layout = require("leetcode-ui.layout")

local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.component.button")
local Title = require("leetcode-menu.components.title")

local group = Group:init({ Header:init() })

local function get_stats()
    local spinner = Spinner:init("fetching user stats")

    statistics.solved(function(res)
        group:set_opts({
            spacing = 2,
            padding = {
                top = 4,
                bot = 2,
            },
        })

        group.components = { Solved:init(res), Calendar:init(res) }
        _Lc_Menu:draw()

        spinner:stop(nil, true, { timeout = 200 })
    end)
end
get_stats()

local skills = Button:init({ icon = "", src = "Skills" }, "s", cmd.ui_skills)

local languages = Button:init({ icon = "", src = "Languages" }, "l", cmd.ui_languages)

local update = Button:init({ icon = "", src = "Update" }, "u", get_stats)

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
