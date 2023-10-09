local cmd = require("leetcode.command")

local Title = require("leetcode-menu.components.title")
local Footer = require("leetcode-menu.components.footer")
local Header = require("leetcode-menu.components.header")

local Button = require("leetcode-ui.component.button")
local Buttons = require("leetcode-menu.components.buttons")
local Layout = require("leetcode-ui.layout")

local list_btn = Button:init({ src = "List", icon = "" }, "p", function() cmd.problems() end)

local random_btn = Button:init(
    { src = "Random", icon = "" },
    "r",
    function() cmd.random_question() end
)

local qot_btn = Button:init({ src = "Daily", icon = "󰃭" }, "t", function() cmd.qot() end)

local lang_btn = Button:init(
    { src = "Language", icon = "󰢱" },
    "l",
    function() cmd.change_lang() end
)

local back_btn = Button:init(
    { src = "Back", icon = "" },
    "q",
    function() cmd.menu_layout("menu") end
)

return Layout:init({
    components = {
        -- header
        Header:init(),

        -- title
        Title:init("Problems"),

        -- buttons
        Buttons:init({
            components = {
                list_btn,
                random_btn,
                qot_btn,
                lang_btn,
                back_btn,
            },
        }),

        --footer
        Footer:init(),
    },
    opts = {},
})
