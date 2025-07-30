local m = require("markup")
local log = require("leetcode.logger")
local Title = require("leetcode.ui.menu.title")

local Nav = m.component(function()
    local menu = m.hooks.use(Leet.ctx.menu)
    local Items = require("leetcode.ui.menu.nav." .. menu.page)

    return m.vflex({
        spacing = 1,
        align = "center",
        children = {
            Title(),
            Items(),
        },
    })
end)

return Nav
