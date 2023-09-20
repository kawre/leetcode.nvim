local config = require("leetcode.config")
local log = require("leetcode.logger")

local template = require("leetcode.ui.dashboard.template")
local section = template.section

section.title.val = "Cookie"

section.buttons.val = {
    template.button(
        "s",
        "󱛪 " .. " Sign out / Delete cookie ",
        "<cmd>lua require('leetcode.utils').remove_cookie()<cr>"
    ),
    template.button(
        "s",
        "󱛬 " .. " Update ",
        "<cmd>lua require('leetcode.api').cmd.cookie_prompt()<cr>"
    ),
    template.button(
        "q",
        " " .. " Back",
        "<cmd>lua require('leetcode.api').cmd.dashboard('menu')<cr>"
    ),
}

return {
    layout = {
        -- header
        { type = "padding", val = 2 },
        section.header,

        -- notifications
        { type = "padding", val = 2 },
        section.notifications,
        { type = "padding", val = 2 },

        -- title
        section.title,

        -- buttons
        section.buttons,

        --footer
        section.footer,
    },
    opts = {
        margin = 5,
    },
}
