local m = require("markup")
local Items = require("leetcode.ui.menu.items")
local Item = require("leetcode.ui.menu.item")
local ProblemCard = require("leetcode.ui.menu.problem_card")
local data = require("leetcode.ui.menu.data")
local recent = require("leetcode.ui.menu.recent")
local t = require("leetcode.translator")
local kit = require("leetcode.ui.kit")

--- The problem worked on last, if any.
local function Continue(width)
    local item = recent.list(1)[1]
    if not item then
        return
    end

    return ProblemCard({
        label = t("Continue"),
        icon = kit.icons.resume,
        lhs = "c",
        width = width,
        problem = item.problem,
        extra = recent.ago(item.time),
        click = "double",
        on_press = function()
            require("leetcode.cmd").open(item.problem)
        end,
    })
end

--- The daily challenge, which arrives a moment after the menu.
local function Today(width)
    return function()
        local problem = data.daily()

        return ProblemCard({
            label = t("Daily challenge"),
            icon = kit.icons.calendar,
            aside = os.date("%b %-d"),
            accent = true,
            lhs = "t",
            width = width,
            problem = problem,
            extra = problem and problem.ac_rate and ("%.1f%% accepted"):format(problem.ac_rate),
            click = "double",
            on_press = function()
                require("leetcode.cmd").qot()
            end,
        })
    end
end

return m.component(function(props)
    return m.block({
        -- Half cell edges are the space between the cards.
        m.vflex({ Continue(props.width), Today(props.width) }),
        m.block({ margin = { 1, 0 }, padding = { 0, 1 }, m.inline(("─"):rep(props.width - 2), "leetcode_divider") }),
        Items({
            Item({ icon = "\u{f452}", title = "Problems", desc = "browse, random, recent", lhs = "p", page = "menu.problems" }),
            Item({ icon = "\u{f201}", title = "Statistics", desc = "progress and skills", lhs = "s", page = "menu.statistics" }),
            Item({ icon = "\u{f0198}", title = "Account", desc = "cookie, sign out", lhs = "a", page = "menu.cookie" }),
            Item({
                icon = "\u{f0a48}",
                title = "Quit",
                desc = "close leetcode.nvim",
                lhs = "q",
                on_submit = function()
                    require("leetcode").stop()
                end,
            }),
        }),
    })
end)
