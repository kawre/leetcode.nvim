local m = require("markup")
local log = require("leetcode.logger")
local Title = require("leetcode.ui.menu.title")

local Nav = m.component(function()
    return m.vflex({
        spacing = 1,
        align = "center",
        children = {
            Title(),
            function()
                return require("leetcode.ui.menu.nav." .. Leet.menu.page())()
            end,
        },
    })
end)

return Nav
