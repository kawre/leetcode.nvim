local cmd = require("leetcode.command")

local Title = require("leetcode-ui.lines.title")
local Footer = require("leetcode-ui.lines.footer")
local Header = require("leetcode-ui.lines.menu-header")

local Button = require("leetcode-ui.lines.button.menu")
local Buttons = require("leetcode-ui.group.buttons")
local Page = require("leetcode-ui.group.page")

local page = Page()

page:insert(Header())

page:insert(Title({ "Menu" }, "Problems"))

local list_btn = Button("List", {
    icon = "",
    sc = "p",
    on_press = cmd.problems,
})

local random_btn = Button("Random", {
    icon = "",
    sc = "r",
    on_press = cmd.random_question,
})

local qot_btn = Button("Daily", {
    icon = "󰃭",
    sc = "d",
    on_press = cmd.qot,
})

local back_btn = Button("Back", {
    icon = "",
    sc = "q",
    on_press = function() cmd.menu_layout("menu") end,
})

page:insert(Buttons({
    list_btn,
    random_btn,
    qot_btn,
    back_btn,
}))

page:insert(Footer())

return page
