local Header = require("leetcode-menu.components.header")
local Title = require("leetcode-menu.components.title")
local Button = require("leetcode-ui.component.button")
local Footer = require("leetcode-menu.components.footer")
local Buttons = require("leetcode-menu.components.buttons")
local Layout = require("leetcode-ui.layout")
local cmd = require("leetcode.command")

local update_btn = Button:init(
    { icon = "󱘴", src = "Update" },
    "u",
    function() cmd.cache_update() end
)

local back_btn = Button:init(
    { icon = "", src = "Back" },
    "q",
    function() cmd.menu_layout("menu") end
)

local buttons = Buttons:init({
    components = {
        update_btn,
        back_btn,
    },
})

return Layout:init({
    components = {
        Header:init(),

        Title:init({ "Menu" }, "Cache"),

        buttons,

        Footer:init(),
    },
    opts = {
        margin = 5,
    },
})
