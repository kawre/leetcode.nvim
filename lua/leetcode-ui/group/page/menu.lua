local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Header = require("leetcode-ui.lines.menu-header")
local Footer = require("leetcode-ui.lines.footer")
local stats = require("leetcode-ui.lines.stats")

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
    expandable = true,
})

local statistics = Button("Statistics", {
    icon = "󰄪",
    sc = "s",
    on_press = function() cmd.menu_layout("stats") end,
    expandable = true,
})

local cookie = Button("Cookie", {
    icon = "󰆘",
    sc = "i",
    on_press = function() cmd.menu_layout("cookie") end,
    expandable = true,
})

local cache = Button("Cache", {
    icon = "",
    sc = "c",
    on_press = function() cmd.menu_layout("cache") end,
    expandable = true,
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

page:insert(stats)

return page
