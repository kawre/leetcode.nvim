local m = require("markup")
local Title = require("leetcode.ui.menu.title")

local Nav = m.component(function()
    -- Rows only make an entrance on a new page, not when the dashboard reflows.
    local mounted = false

    return m.block({
        Title(),
        function()
            Leet.menu.rows = 0
            Leet.menu.rows_enter = mounted or not Leet.menu.settled()
            mounted = true
            return require("leetcode.ui.menu.nav." .. Leet.menu.page())()
        end,
    })
end)

return Nav
