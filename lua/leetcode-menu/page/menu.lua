local Page = require("leetcode-menu.page")
local Title = require("leetcode-menu.components.title")
local Buttons = require("leetcode-menu.components.buttons")
local Button = require("leetcode-ui.lines.button")

local cmd = require("leetcode.command")
local log = require("leetcode.logger")

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

local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

return Page({
    Header(),

    Title({}, "Menu"),

    Buttons({
        problems,
        statistics,
        cookie,
        cache,
        exit,
    }),

    Footer(),
})
