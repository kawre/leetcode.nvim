local log = require("leetcode.logger")
local cmd = require("leetcode.api.command")

local Title = require("leetcode-menu.components.title")
local Footer = require("leetcode-menu.components.footer")
local Header = require("leetcode-menu.components.header")

local group = require("leetcode-ui.component.group")
local padding = require("leetcode-ui.component.padding")
local button = require("leetcode-ui.component.button")
local layout = require("leetcode-ui.layout")

local list_btn = button:init({ src = "List", icon = "" }, "p", function() cmd.problems() end)

local random_btn = button:init(
    { src = "Random", icon = "" },
    "r",
    function() cmd.random_question() end
)

local qot_btn = button:init(
    { src = "Question of Today", icon = "󰃭" },
    "t",
    function() cmd.qot() end
)

local back_btn = button:init(
    { src = "Back", icon = "" },
    "q",
    function() cmd.menu_layout("menu") end
)

local buttons = group:init({
    components = {
        list_btn,
        random_btn,
        qot_btn,
        back_btn,

        -- button:init("t", "Question of Today", " "),
        -- button:init("t", "Random", " "),
        -- button:init("r", "Recent", " "),
        -- button:init("q", "Back", "… "),
    },
    opts = { spacing = 1 },
})

return layout:init({
    contents = {
        -- header
        Header:init():content(),

        -- title
        Title:init("Problems"):content(),

        -- buttons
        buttons,

        --footer
        Footer:init():content(),
    },
    opts = {},
})
