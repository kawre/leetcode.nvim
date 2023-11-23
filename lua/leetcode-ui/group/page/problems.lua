local cmd = require("leetcode.command")

local Title = require("leetcode-ui.lines.title")
local Footer = require("leetcode-ui.lines.footer")
local Header = require("leetcode-ui.lines.menu-header")

local Button = require("leetcode-ui.lines.button")
local Buttons = require("leetcode-ui.group.buttons")
local Page = require("leetcode-ui.group.page")

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
