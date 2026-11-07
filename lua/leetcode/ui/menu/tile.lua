--- A way to go from the menu, on a surface of its own. The half cell edges of
--- the surface leave a full cell between tiles.

local m = require("markup")
local kit = require("leetcode.ui.kit")

local animate = Markup.animate

---@class leet.ui.menu.tile
---@field title string
---@field icon string
---@field lhs string
---@field desc? string
---@field page? string
---@field nested? boolean
---@field on_submit? function

---@param p leet.ui.menu.tile
return m.component(function(p)
    local function press()
        if p.on_submit then
            p.on_submit()
        elseif p.page then
            Leet.menu.set_page(p.page)
        end
    end

    m.use_key(p.lhs, press, { noremap = false, silent = true, nowait = true })

    -- Tiles of a page arrive one after another.
    Leet.menu.rows = Leet.menu.rows + 1
    local delay = Leet.menu.rows * 35
    local enter = Leet.menu.rows_enter
    local surface = kit.color("leetcode_surface", "bg")

    local function fade(group)
        return enter and animate.fade_in(group, surface, { delay = delay, duration = 200 }) or group
    end

    local slide = m.animated(enter and 2 or 0, { delay = delay, duration = 200 })
    slide(0)

    local focus = m.animated(0, { duration = 110 })
    local tint = animate.tint({ bg = surface }, { bg = kit.color("leetcode_row_active", "bg") }, focus)
    local title = fade("leetcode_strong")

    return kit.Card({
        on_press = press,
        on_hover = function(hovered)
            focus(hovered and 1 or 0)
        end,
        style = tint,
        m.flex({
            justify = "between",
            m.inline({
                margin_left = function()
                    return math.floor(slide() + 0.5)
                end,
                m.inline(p.icon .. " ", fade("Character")),
                m.inline({
                    style = function()
                        return focus() > 0.5 and "leetcode_accent" or title
                    end,
                    p.title,
                }),
                p.nested and m.inline(" \u{eab6}", fade("leetcode_muted")),
            }),
            kit.Key(p.lhs),
        }),
        p.desc and m.block({
            margin_left = function()
                return 2 + math.floor(slide() + 0.5)
            end,
            m.inline(p.desc, fade("leetcode_muted")),
        }),
    })
end)
