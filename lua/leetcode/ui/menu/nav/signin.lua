local m = require("markup")
local Buttons = require("leetcode.ui.menu.tiles")
local Button = require("leetcode.ui.menu.tile")

return m.component(function()
    local cmd = require("leetcode.cmd")

    return m.block({
        m.block({ margin_bottom = 1, padding = { 0, 1 }, m.inline("please sign in", "leetcode_muted") }),
        Buttons({
            Button({ icon = "\u{f0306}", title = "Cookie", desc = "Paste your session cookie", lhs = "i", on_submit = cmd.cookie_prompt }),
            Button({
                icon = "\u{f0a48}",
                title = "Exit",
                desc = "Close leetcode.nvim",
                lhs = "qa",
                on_submit = function()
                    require("leetcode").stop()
                end,
            }),
        }),
    })
end)
