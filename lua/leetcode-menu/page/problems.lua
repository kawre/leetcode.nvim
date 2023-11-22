local cmd = require("leetcode.command")

local Title = require("leetcode-menu.components.title")
local Footer = require("leetcode-menu.components.footer")
local Header = require("leetcode-menu.components.header")

local Button = require("leetcode-ui.lines.button")
local Buttons = require("leetcode-menu.components.buttons")
local Page = require("leetcode-menu.page")

local page = Page()

page:insert(Header())

page:insert(Title({ "Menu" }, "Problems"))

local list_btn = Button({ src = "List", icon = "" }, "p", cmd.problems)
local random_btn = Button({ src = "Random", icon = "" }, "r", cmd.random_question)
local qot_btn = Button({ src = "Daily", icon = "󰃭" }, "d", cmd.qot)
local back_btn = Button({ src = "Back", icon = "" }, "q", function() cmd.menu_layout("menu") end)

page:insert(Buttons({
    list_btn,
    random_btn,
    qot_btn,
    back_btn,
}))

page:insert(Footer())

return page
