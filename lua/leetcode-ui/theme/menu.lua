local layout = require("leetcode-ui.layout")
local template = require("leetcode-ui.theme.template")
local padding = require("leetcode-ui.component.padding")
local button = require("leetcode-ui.component.button")
local group = require("leetcode-ui.component.group")

local section = template.section

local problems = button:init(
    "p",
    "Problems",
    "",
    true
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('problems')<CR>"
)
local statistics = button:init(
    "s",
    "Statistics",
    "󰄪",
    true
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('stats')<cr>"
)
local cookie = button:init(
    "c",
    "Cookie",
    "󰆘",
    true
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('cookie')<cr>"
)
local cache = button:init(
    "n",
    "Cache",
    "",
    true
    -- "<cmd>lua require('leetcode.api').cmd.dashboard('cache')<cr>"
)
local exit = button:init("q", "Exit", "󰩈")

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

section.title:append("Menu", "Comment")

section.footer:append("Signed in as: " .. "kawre", "Keyword")

local menu = layout:init({
    contents = {
        padding:init(2),
        section.header,
        padding:init(2),

        -- section.notifications,
        -- padding:init(2),

        section.title,

        padding:init(1),
        buttons,
        padding:init(1),

        section.footer,
    },
    opts = {
        margin = 5,
    },
})

return menu
