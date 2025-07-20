local markup = require("markup")
local log = require("leetcode.logger")

---@class MenuButtonProps
---@field title string
---@field icon string
---@field key string
---@field page string
---@field nested boolean
---@field on_submit function

---@param props MenuButtonProps
return markup.Component(function(props)
    local p = props

    local on_submit = p.on_submit

    if not on_submit and p.page then
        on_submit = function()
            _Lc_state.menu:set_page(p.page)
        end
    end

    return markup.block({
        -- on_submit = on_submit,
        -- on_key = {
        --     [p.key] = on_submit,
        -- },
        markup.flex({
            spacing = 1,
            markup.inline(p.icon, "leetcode_menu_button_icon"),
            markup.inline(p.title, "leetcode_menu_button_title"),
            -- p.nested and markup.inline("", "leetcode_menu_button_nested"),
            p.nested and markup.inline("E", "leetcode_menu_button_nested"),
        }),
        markup.Inline(p.key, "leetcode_menu_button_key"),
    })
end)
