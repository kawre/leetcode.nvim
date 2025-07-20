local markup = require("markup")
local config = require("leetcode.config")

return markup.Component(function()
    return markup.block({
        margin_left = 1,
        margin_top = 1,
        margin_bottom = 1,
        margin_right = 1,
        markup.inline("signed in as: ", "leetcode_menu_footer"),
        markup.inline(config.auth.name or "no user", "leetcode_menu_footer_username"),
    })
end)
