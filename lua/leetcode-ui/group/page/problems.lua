local cmd = require("leetcode.command")
local config = require("leetcode.config")

local Title = require("leetcode-ui.lines.title")
local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Page = require("leetcode-ui.group.page")

local footer = require("leetcode-ui.lines.footer")
local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)

page:insert(Title({ "Menu" }, "Problems"))

local list = Button("List", {
    icon = "",
    sc = "p",
    on_press = cmd.problems,
})

local random = Button("Random", {
    icon = "",
    sc = "r",
    on_press = cmd.random_question,
})

local daily = Button("Daily", {
    icon = "󰃭",
    sc = "d",
    on_press = cmd.qot,
})

local companies = Button("Companies", {
    icon = "",
    sc = "c",
    on_press = cmd.companies,
})

local back = BackButton("menu")

button_list = { list, random, daily }
if config.auth.is_premium then
    table.insert(button_list, companies)
end
table.insert(button_list, back)

page:insert(Buttons(button_list))

page:insert(footer)

return page
