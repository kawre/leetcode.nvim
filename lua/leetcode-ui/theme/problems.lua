local log = require("leetcode.logger")
local group = require("leetcode-ui.component.group")
local button = require("leetcode-ui.component.button")
local layout = require("leetcode-ui.layout")

local template = require("leetcode-ui.theme.template")
local section = template.section

section.title:append("Problems")

local buttons = group:init({
    components = {
        button:init("p", "List", ""),
        button:init("t", "Question of Today", "󰃭 "),
        button:init("t", "Random", " "),
        button:init("r", "Recent", " "),
        button:init("q", "Back", "… "),
    },
    opts = { spacing = 1 },
})

section.footer:append("Signed in as: ")

return layout:init({
    contents = {
        -- header
        section.header,

        -- notifications
        section.notifications,

        -- title
        section.title,

        -- buttons
        buttons,

        --footer
        section.footer,
    },
    opts = {},
})
