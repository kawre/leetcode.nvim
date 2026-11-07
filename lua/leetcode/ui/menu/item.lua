--- One line of the launcher: a name, what it does, and its key.

local m = require("markup")
local kit = require("leetcode.ui.kit")

local animate = Markup.animate

--- Room for the name, so that descriptions start in one column.
local TITLE_WIDTH = 12

---@class leet.ui.menu.item
---@field title string
---@field icon? string
---@field lhs string
---@field desc? string|fun(): any text, or what to show
---@field page? string
---@field on_submit? function

---@param p leet.ui.menu.item
return m.component(function(p)
    local function press()
        if p.on_submit then
            p.on_submit()
        elseif p.page then
            Leet.menu.set_page(p.page)
        end
    end

    m.use_key(p.lhs, press, { noremap = false, silent = true, nowait = true })

    -- Items of a page arrive one after another.
    Leet.menu.rows = Leet.menu.rows + 1
    local delay = Leet.menu.rows * 35
    local enter = Leet.menu.rows_enter
    local background = kit.color("Normal", "bg")

    local function fade(group)
        return enter and animate.fade_in(group, background, { delay = delay, duration = 200 }) or group
    end

    local focus = m.animated(0, { duration = 110 })
    local tint = animate.tint({ bg = background }, { bg = kit.color("leetcode_row_active", "bg") }, focus)
    local title = fade("leetcode_strong")
    local muted = fade("leetcode_muted")
    local icon = fade("Character")

    local desc = p.desc
    if type(desc) == "string" then
        desc = m.inline(desc, muted)
    end

    return m.flex({
        on_press = press,
        on_hover = function(hovered)
            focus(hovered and 1 or 0)
        end,
        -- Nothing behind it at rest, as the window decides that color.
        style = function()
            return focus() > 0.01 and tint or nil
        end,
        justify = "between",
        white_space = "nowrap",
        m.inline({
            shrink = 1,
            m.inline(function()
                return focus() > 0.5 and "▌" or " "
            end, "leetcode_accent"),
            p.icon and m.inline({
                margin_left = 1,
                style = function()
                    return focus() > 0.5 and "leetcode_accent" or icon
                end,
                p.icon,
            }),
            m.inline({
                margin_left = 1,
                width = TITLE_WIDTH,
                shrink = 0,
                style = function()
                    return focus() > 0.5 and "leetcode_accent" or title
                end,
                p.title,
            }),
            desc and m.inline({ shrink = 1, desc }),
        }),
        m.inline({ shrink = 0, margin_left = 2, margin_right = 1, kit.Key(p.lhs) }),
    })
end)
