local m = require("markup")
local log = require("leetcode.logger")
local Title = require("leetcode.ui.menu.title")

local Nav = m.Component(function()
    local menu = m.use(Leet.ctx.menu)
    local Items = require("leetcode.ui.menu.nav." .. menu.page)

    return m.vflex({
        spacing = 1,
        margin = 1,
        align = "center",
        width = 50,
        children = {
            Title(),
            Items(),
        },
    })
end)

return Nav
