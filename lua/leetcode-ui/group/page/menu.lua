local cmd = require("leetcode.command")

local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Button = require("leetcode-ui.lines.button.menu")
local ExitButton = require("leetcode-ui.lines.button.menu.exit")

local header = require("leetcode-ui.lines.menu-header")
local footer = require("leetcode-ui.lines.footer")

local page = Page()

page:insert(header)

page:insert(Title({}, "Menu"))

local problems = Button("Problems", {
    icon = "",
    sc = "p",
    on_press = function()
        cmd.set_menu_page("problems")
    end,
    expandable = true,
})

local statistics = Button("Statistics", {
    icon = "󰄪",
    sc = "s",
    on_press = function()
        cmd.set_menu_page("stats")
    end,
    expandable = true,
})

local cookie = Button("Cookie", {
    icon = "󰆘",
    sc = "i",
    on_press = function()
        cmd.set_menu_page("cookie")
    end,
    expandable = true,
})

local cache = Button("Cache", {
    icon = "",
    sc = "c",
    on_press = function()
        cmd.set_menu_page("cache")
    end,
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

page:insert(footer)

return page
