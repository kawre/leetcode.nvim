local m = require("markup")

---@class MenuButtonProps
---@field title string
---@field icon string
---@field key string
---@field page string
---@field nested boolean
---@field on_submit function

---@param p MenuButtonProps
return m.component(function(p)
    local menu = m.hooks.use(Leet.ctx.menu)
    local win = m.hooks.window()

    local function change_page()
        if not p.on_submit and p.page then
            menu.set_page(p.page)
        else
            p.on_submit()
        end
    end

    m.hooks.effect(function()
        return win:map("n", p.key, change_page, {
            noremap = false,
            silent = true,
            nowait = true,
        })
    end, {})

    return m.flex({
        -- on_confirm = on_submit,
        justify = "between",
        m.flex({
            spacing = 1,
            m.button(p.icon, "Character"),
            m.inline(p.title, "Tag"),
            p.nested and m.inline("", "leetcode_menu_button_nested"),
        }),
        m.block(p.key, "Type"),
    })
end)
