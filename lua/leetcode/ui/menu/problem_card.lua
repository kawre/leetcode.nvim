--- A problem worth going to straight from the menu, on a card of its own.

local m = require("markup")
local kit = require("leetcode.ui.kit")
local config = require("leetcode.config")
local t = require("leetcode.translator")
local ui = require("leetcode.ui.util")

local animate = Markup.animate

local status_labels = { ac = "Solved", notac = "Attempted", todo = "Not solved" }

---@class leet.ui.menu.problem_card
---@field label string what the problem is to the user
---@field icon string
---@field aside? string beside the key, such as a date
---@field accent? boolean warm, and the label always lit, for what stands out
---@field lhs string
---@field width integer
---@field problem? leet.cache.problem nil while it is on its way
---@field extra? string after the status and difficulty
---@field on_press function

---@param props leet.ui.menu.problem_card
return m.component(function(props)
    m.use_key(props.lhs, props.on_press, { nowait = true })

    local rest = props.accent and "leetcode_daily" or "leetcode_surface"
    local active = props.accent and "leetcode_daily_active" or "leetcode_row_active"
    local focus = m.animated(0, { duration = 110 })
    local tint = animate.tint({ bg = kit.color(rest, "bg") }, { bg = kit.color(active, "bg") }, focus)

    local function body()
        local problem = props.problem
        if not problem then
            return m.block({ kit.Loading(), m.block(" ") })
        end

        local status = config.icons.hl.status[problem.status]
        local number = problem.frontend_id .. ". "
        local title = Leet.util.translate(problem.title, problem.title_cn)
        local separator = m.inline(" · ", "leetcode_muted")

        return m.block({
            m.block({
                white_space = "nowrap",
                m.inline(number, "leetcode_muted"),
                m.inline(kit.truncate(title, props.width - 4 - vim.api.nvim_strwidth(number)), "leetcode_strong"),
            }),
            m.block({
                white_space = "nowrap",
                m.inline(
                    t(status_labels[problem.status] or status_labels.todo),
                    status and status[2] or "leetcode_muted"
                ),
                separator,
                m.inline(t(problem.difficulty), ui.diff_to_hl(problem.difficulty)),
                props.extra and separator,
                props.extra and m.inline(props.extra, "leetcode_muted"),
            }),
        })
    end

    return kit.Card({
        width = props.width,
        click = "double",
        on_press = props.on_press,
        on_hover = function(hovered)
            focus(hovered and 1 or 0)
        end,
        style = tint,
        m.flex({
            justify = "between",
            margin_bottom = 1,
            m.inline({
                style = function()
                    return (props.accent or focus() > 0.5) and "leetcode_accent" or "leetcode_muted"
                end,
                m.inline(props.icon .. " "),
                m.inline(props.label, props.accent and "leetcode_accent" or nil),
            }),
            m.inline({
                props.aside and m.inline(props.aside .. "  ", "leetcode_muted"),
                kit.Key(props.lhs),
            }),
        }),
        body(),
    })
end)
