local m = require("markup")
local Items = require("leetcode.ui.menu.items")
local Item = require("leetcode.ui.menu.item")
local BackButton = require("leetcode.ui.menu.button.back")

return m.component(function()
    local cmd = require("leetcode.cmd")

    return Items({
        Item({ title = "Cookie", desc = "paste a new session cookie", lhs = "u", on_submit = cmd.cookie_prompt }),
        Item({ title = "Sign out", desc = "forget this session", lhs = "d", on_submit = cmd.sign_out }),
        BackButton({ page = "menu" }),
    })
end)
