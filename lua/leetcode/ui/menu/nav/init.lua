local m = require("markup")
local Title = require("leetcode.ui.menu.title")

local Nav = m.component(function()
    return m.block({
        Title(),
        function()
            Leet.menu.rows = 0
            return require("leetcode.ui.menu.nav." .. Leet.menu.page())()
        end,
    })
end)

return Nav
