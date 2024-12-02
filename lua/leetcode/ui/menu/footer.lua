local markup = require("markup")
local config = require("leetcode.config")

return markup.Component(function()
    return markup.Inline({
        markup.Inline("signed in as: ", "leetcode_menu_footer"),
        markup.Inline(config.auth.name or "no user", "leetcode_menu_footer_username"),
    })
end)
