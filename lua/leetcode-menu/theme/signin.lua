local Layout = require("leetcode-ui.layout")
local Title = require("leetcode-menu.components.title")
local cmd = require("leetcode.api.command")

local padding = require("leetcode-ui.component.padding")
local button = require("leetcode-ui.component.button")
local group = require("leetcode-ui.component.group")

local problems = button:init(
    { icon = "󱛖", src = "Sign in (By Cookie)" },
    "s",
    function() cmd.cookie_prompt() end,
    false
)

local exit = button:init({ src = "Exit", icon = "󰩈" }, "q", function() vim.cmd.quitall() end)

local buttons = group:init({
    components = {
        problems,
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

return Layout:init({
    contents = {
        Header:init():content(),

        Title:init("Sign in"):content(),
        --
        buttons,
        --
        Footer:init():content(),
    },
    opts = {
        margin = 5,
    },
})
