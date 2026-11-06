local m = require("markup")

---@class MenuButtonProps
---@field title string
---@field icon string
---@field lhs string
---@field page string
---@field nested boolean
---@field on_submit function

---@param p MenuButtonProps
return m.component(function(p)
    local function press()
        if p.on_submit then
            p.on_submit()
        elseif p.page then
            Leet.menu.set_page(p.page)
        end
    end

    m.use_key(p.lhs, press, { noremap = false, silent = true, nowait = true })

    return m.flex({
        on_press = press,
        justify = "between",
        m.flex({
            spacing = 1,
            m.inline(p.icon, "Character"),
            m.inline(p.title, "Tag"),
            p.nested and m.inline("", "leetcode_menu_button_nested"),
        }),
        m.block(p.lhs, "Type"),
    })
end)
