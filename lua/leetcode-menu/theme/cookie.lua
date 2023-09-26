local Header = require("leetcode-menu.components.header")
local Title = require("leetcode-menu.components.title")
local Button = require("leetcode-ui.component.button")
local Group = require("leetcode-ui.component.group")
local Footer = require("leetcode-menu.components.footer")
local Buttons = require("leetcode-menu.components.buttons")

local Layout = require("leetcode-ui.layout")

local config = require("leetcode.config")
local log = require("leetcode.logger")
local cmd = require("leetcode.api.command")

local update_btn = Button:init(
    { icon = "󱛬", src = "Update" },
    "u",
    function() cmd.cookie_prompt() end
)

local delete_btn = Button:init(
    { icon = "󱛪", src = "Delete / Sign out" },
    "d",
    function() cmd.cookie_prompt() end
)

local back_btn = Button:init(
    { icon = "", src = "Back" },
    "q",
    function() cmd.menu_layout("menu") end
)

local buttons = Buttons:init({
    components = {
        update_btn,
        delete_btn,
        back_btn,
    },
})

return Layout:init({
    components = {
        Header:init(),

        Title:init("Cookie"),

        buttons,

        Footer:init(),
    },
    opts = {
        margin = 5,
    },
})
