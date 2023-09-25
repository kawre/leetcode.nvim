local log = require("leetcode.logger")
local layout = require("leetcode-ui.layout")
local Title = require("leetcode-menu.components.title")
local cmd = require("leetcode.api.command")

local padding = require("leetcode-ui.component.padding")
local button = require("leetcode-ui.component.button")
local group = require("leetcode-ui.component.group")

local problems = button:init(
    { icon = "", src = "Problems" },
    "p",
    function() cmd.menu_layout("problems") end,
    true
)

local statistics = button:init({ icon = "󰄪", src = "Statistics" }, "s", function() end, true)

local cookie = button:init(
    { src = "Cookie", icon = "󰆘" },
    "c",
    function() cmd.menu_layout("cookie") end,
    true
)

local cache = button:init(
    { src = "Cache", icon = "" },
    "n",
    function() cmd.menu_layout("cache") end,
    true
)

local exit = button:init({ src = "Exit", icon = "󰩈" }, "q", function() vim.cmd.quitall() end)

local buttons = group:init({
    components = {
        problems,
        statistics,
        cookie,
        cache,
        exit,
    },
    opts = {
        spacing = 1,
    },
})

-- section.title:append("Menu", "Comment")

-- section.footer:append("Signed in as: " .. "kawre", "Keyword")

local Header = require("leetcode-menu.components.header")
local Footer = require("leetcode-menu.components.footer")

return layout:init({
    contents = {
        Header:init():content(),

        -- section.notifications,
        -- padding:init(2),

        -- section.title,
        Title:init("Menu"):content(),

        buttons,

        Footer:init():content(),
    },
    opts = {
        margin = 5,
    },
})
