local Page = require("leetcode-menu.page")
local Title = require("leetcode-menu.components.title")
local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.lines.button")
local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

local cmd = require("leetcode.command")

local page = Page()

page:insert(Header())

page:insert(Title({}, "Menu"))

local problems = Button(
    { icon = "", src = "Problems" },
    "p",
    function() cmd.menu_layout("problems") end,
    true
)

local statistics = Button(
    { icon = "󰄪", src = "Statistics" },
    "s",
    function() cmd.menu_layout("stats") end,
    true
)

local cookie = Button(
    { src = "Cookie", icon = "󰆘" },
    "i",
    function() cmd.menu_layout("cookie") end,
    true
)

local cache = Button(
    { src = "Cache", icon = "" },
    "c",
    function() cmd.menu_layout("cache") end,
    true
)

local exit = Button({ src = "Exit", icon = "󰩈" }, "q", vim.cmd.quitall)

page:insert(Buttons({
    problems,
    statistics,
    cookie,
    cache,
    exit,
}))

page:insert(Footer())

return page
