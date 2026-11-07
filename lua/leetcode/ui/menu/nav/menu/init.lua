local m = require("markup")
local Items = require("leetcode.ui.menu.items")
local Item = require("leetcode.ui.menu.item")
local Continue = require("leetcode.ui.menu.continue")
local data = require("leetcode.ui.menu.data")
local kit = require("leetcode.ui.kit")

--- The daily challenge, by number and title.
local function today()
    local problem = data.daily()
    if not problem then
        return kit.Loading()
    end

    return m.inline({
        m.inline(problem.frontend_id .. ". ", "leetcode_muted"),
        m.inline(kit.truncate(Leet.util.translate(problem.title, problem.title_cn), 30)),
    })
end

return m.component(function(props)
    return m.block({
        Continue({ width = props.width }),
        Items({
            Item({
                title = "Today",
                desc = today,
                lhs = "t",
                on_submit = function()
                    require("leetcode.cmd").qot()
                end,
            }),
        }),
        m.block({ margin = { 1, 0 }, padding = { 0, 1 }, m.inline(("─"):rep(props.width - 2), "leetcode_divider") }),
        Items({
            Item({ title = "Problems", desc = "browse, random, recent", lhs = "p", page = "menu.problems" }),
            Item({ title = "Statistics", desc = "progress and skills", lhs = "s", page = "menu.statistics" }),
            Item({ title = "Account", desc = "cookie, sign out", lhs = "a", page = "menu.cookie" }),
            Item({
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
