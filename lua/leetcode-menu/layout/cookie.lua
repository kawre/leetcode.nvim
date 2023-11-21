local Header = require("leetcode-menu.components.header")
local Title = require("leetcode-menu.components.title")
local Button = require("leetcode-ui.component.button")
local Footer = require("leetcode-menu.components.footer")
local Buttons = require("leetcode-menu.components.buttons")
local Layout = require("leetcode-ui.layout")

local cmd = require("leetcode.command")

local update_btn = Button({ icon = "󱛬", src = "Update" }, "u", cmd.cookie_prompt)

local delete_btn = Button({ icon = "󱛪", src = "Delete / Sign out" }, "d", cmd.sign_out)

local back_btn = Button({ icon = "", src = "Back" }, "q", function() cmd.menu_layout("menu") end)

local buttons = Buttons({
    update_btn,
    delete_btn,
    back_btn,
})

return Layout({
    Header(),

    Title({ "Menu" }, "Cookie"),

    buttons,

    Footer(),
})
