local config = require("leetcode.config")

local template = require("leetcode.ui.dashboard.template")
local section = template.section
local auth = config.auth

section.title.val = "Cache"

section.buttons.val = {
    template.button(
        "c",
        "󱘴 " .. " Update",
        "<cmd>lua require('leetcode.api').cmd.cookie_prompt()<cr>"
    ),
    template.button(
        "s",
        " " .. " Sign out",
        "<cmd>lua require('leetcode.utils').remove_cookie()<cr>"
    ),
    template.button("q", "󰩈 " .. " Exit LeetCode", "<cmd>qa<CR>"),
}

section.footer.val = "Signed in as: " .. auth.name

return {
    layout = {
        -- header
        { type = "padding", val = 2 },
        section.header,

        -- notifications
        -- { type = "padding", val = 2 },
        -- section.notifications,
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
