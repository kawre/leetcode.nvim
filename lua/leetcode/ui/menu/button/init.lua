local m = require("markup")
local kit = require("leetcode.ui.kit")

local animate = Markup.animate

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

    -- Rows of a page arrive one after another.
    Leet.menu.rows = Leet.menu.rows + 1
    local delay = Leet.menu.rows * 25
    local surface = kit.color("leetcode_surface", "bg")

    local enter = Leet.menu.rows_enter

    local function fade(group)
        return enter and animate.fade_in(group, surface, { delay = delay, duration = 140 }) or group
    end

    local slide = m.animated(enter and 2 or 0, { delay = delay, duration = 140 })
    slide(0)

    local focus = m.animated(0, { duration = 80 })
    local row = animate.tint(
        { bg = surface },
        { bg = kit.color("leetcode_row_active", "bg") },
        focus
    )

    return m.flex({
        on_press = press,
        on_hover = function(hovered)
            focus(hovered and 1 or 0)
        end,
        style = row,
        justify = "between",
        m.flex({
            m.inline(function()
                return focus() > 0.5 and "▌" or " "
            end, "leetcode_accent"),
            m.inline({
                margin_left = function()
                    return math.floor(slide() + 0.5)
                end,
            }),
            m.inline(p.icon .. " ", fade("Character")),
            m.inline(p.title, fade("leetcode_strong")),
            p.nested and m.inline(" \u{eab6}", fade("leetcode_muted")),
        }),
        m.inline({ margin_right = 1, kit.Key(p.lhs) }),
    })
end)
