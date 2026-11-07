--- The problem the user worked on last, to pick it up again.

local m = require("markup")
local kit = require("leetcode.ui.kit")
local config = require("leetcode.config")
local recent = require("leetcode.ui.menu.recent")
local t = require("leetcode.translator")
local ui = require("leetcode.ui.util")

local animate = Markup.animate

local status_labels = { ac = "Solved", notac = "Attempted", todo = "Not solved" }

return m.component(function(props)
    local item = recent.list(1)[1]
    if not item then
        return
    end

    local problem = item.problem
    local function open()
        require("leetcode.cmd").open(problem)
    end

    m.use_key("c", open, { nowait = true })

    local surface = kit.color("leetcode_surface", "bg")
    local focus = m.animated(0, { duration = 110 })
    local tint = animate.tint({ bg = surface }, { bg = kit.color("leetcode_row_active", "bg") }, focus)

    local status = config.icons.hl.status[problem.status]
    local number = problem.frontend_id .. ". "
    local title = Leet.util.translate(problem.title, problem.title_cn)
    -- The card, the key and a gap come off the width.
    local room = props.width - 4 - 4 - vim.api.nvim_strwidth(number)

    return kit.Card({
        width = props.width,
        margin_bottom = 1,
        on_press = open,
        on_hover = function(hovered)
            focus(hovered and 1 or 0)
        end,
        style = tint,
        m.flex({
            justify = "between",
            m.inline({
                style = function()
                    return focus() > 0.5 and "leetcode_accent" or "leetcode_muted"
                end,
                t("Continue"),
            }),
            kit.Key("c"),
        }),
        m.block({
            white_space = "nowrap",
            m.inline(number, "leetcode_muted"),
            m.inline(kit.truncate(title, room), "leetcode_strong"),
        }),
        m.block({
            white_space = "nowrap",
            m.inline(t(status_labels[problem.status] or status_labels.todo), status and status[2] or "leetcode_muted"),
            m.inline(" · ", "leetcode_muted"),
            m.inline(t(problem.difficulty), ui.diff_to_hl(problem.difficulty)),
            m.inline(" · " .. recent.ago(item.time), "leetcode_muted"),
        }),
    })
end)
