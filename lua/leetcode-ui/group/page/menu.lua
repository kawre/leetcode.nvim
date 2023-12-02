local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons")
local Header = require("leetcode-ui.lines.menu-header")
local Footer = require("leetcode-ui.lines.footer")

local Button = require("leetcode-ui.lines.button.menu")
local ExitButton = require("leetcode-ui.lines.button.menu.exit")

local cmd = require("leetcode.command")

local page = Page()

page:insert(Header())

page:insert(Title({}, "Menu"))

local problems = Button("Problems", {
    icon = "",
    sc = "p",
    on_press = function() cmd.menu_layout("problems") end,
})

local statistics = Button("Statistics", {
    icon = "󰄪",
    sc = "s",
    on_press = function() cmd.menu_layout("stats") end,
})

local cookie = Button("Cookie", {
    icon = "󰆘",
    sc = "i",
    on_press = function() cmd.menu_layout("cookie") end,
})

local cache = Button("Cache", {
    icon = "",
    sc = "c",
    on_press = function() cmd.menu_layout("cache") end,
})

local exit = ExitButton()

page:insert(Buttons({
    problems,
    statistics,
    cookie,
    cache,
    exit,
}))

page:insert(Footer())

return page
