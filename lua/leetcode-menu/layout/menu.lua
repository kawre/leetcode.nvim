local log = require("leetcode.logger")
local Layout = require("leetcode-ui.layout")
local Title = require("leetcode-menu.components.title")
local cmd = require("leetcode.command")
local Buttons = require("leetcode-menu.components.buttons")

local button = require("leetcode-ui.component.button")

local problems = button:init(
    { icon = "", src = "Problems" },
    "p",
    function() cmd.menu_layout("problems") end,
    true
)

local statistics = button:init(
    { icon = "󰄪", src = "Statistics (Soon)" },
    "s",
    function() log.info("soon") end,
    true
)

local cookie = button:init(
    { src = "Cookie", icon = "󰆘" },
    "i",
    function() cmd.menu_layout("cookie") end,
    true
)

local cache = button:init(
    { src = "Cache", icon = "" },
    "c",
    function() cmd.menu_layout("cache") end,
    true
)

local exit = button:init({ src = "Exit", icon = "󰩈" }, "q", function()
    local ok, err = pcall(vim.cmd.quitall)
    if not ok then log.error(err or "") end
end)

local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

return Layout:init({
    components = {
        Header:init(),

        Title:init({}, "Menu"),

        Buttons:init({
            components = {
                problems,
                statistics,
                cookie,
                cache,
                exit,
            },
        }),

        Footer:init(),
    },
    opts = {
        margin = 5,
    },
})
