local m = require("markup")

---@class MenuButtonProps
---@field title string
---@field icon string
---@field key string
---@field page string
---@field nested boolean
---@field on_submit function

---@param p MenuButtonProps
return m.Component(function(p)
    local menu = m.use(Leet.ctx.menu)
    local view = m.view()

    local function change_page()
        if not p.on_submit and p.page then
            menu.set_page(p.page)
        else
            p.on_submit()
        end
    end

    m.effect(function()
        return view.win:map("n", p.key, change_page, {
            noremap = false,
            silent = true,
            nowait = true,
        })
    end, {})

    return m.flex({
        -- on_confirm = on_submit,
        justify = "between",
        margin = 1,
        -- width = "full",
        m.flex({
            spacing = 1,
            m.button(p.icon, "leetcode_menu_button_icon"),
            m.inline(p.title, "leetcode_menu_button_title"),
            -- p.nested and markup.inline("", "leetcode_menu_button_nested"),
            p.nested and m.inline("E", "leetcode_menu_button_nested"),
        }),
        m.inline(p.key, "leetcode_menu_button_key"),
        -- markup.inline("cwelllllllllllll"),
    })
end)
