local markup = require("markup")
local log = require("leetcode.logger")

return markup.Component(function(self)
    local p = self.props

    local on_submit = p.page and function()
        _Lc_state.menu:set_page(p.page)
    end or p.on_submit

    return markup.HFlex({
        on_submit = on_submit,
        on_key = {
            [p.key] = on_submit,
        },
        children = {
            markup.HFlex({
                spacing = 1,
                size = { width = 50 },
                children = {
                    markup.Inline(p.icon, "leetcode_menu_button_icon"),
                    markup.Inline(p.title, "leetcode_menu_button_title"),
                    markup.If(p.nested, markup.Inline("", "leetcode_menu_button_nested")),
                },
            }),
            markup.Inline(p.key, "leetcode_menu_button_key"),
        },
    })
end)
