local config = require("leetcode.config")
local log = require("leetcode.logger")
local component = require("leetcode-ui.component")

local template = require("leetcode.ui.dashboard.template")
local section = template.section

section.notifications.val = { " Sign in to use LeetCode.nvim" }

section.buttons.val = {
    template.button(
        "s",
        " " .. " Sign in (By Cookie)",
        "<cmd>lua require('leetcode.api').cmd.cookie_prompt()<cr>"
    ),
    template.button("q", "󰩈 " .. " Exit LeetCode", "<cmd>qa!<CR>"),
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

        -- buttons
        section.buttons,

        --footer
        section.footer,
    },
    opts = {
        margin = 5,
    },
}
