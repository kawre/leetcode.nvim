local markup = require("markup")
local log = require("leetcode.logger")
local Title = require("leetcode.ui.menu.title")

local Nav = markup.Component(function(props)
    local page = props.page
    local Items = require("leetcode.ui.menu.nav." .. page)

    return markup.vflex({
        spacing = 1,
        align = "center",
        margin_left = 1,
        margin_top = 1,
        margin_bottom = 1,
        margin_right = 1,
        width = 50,
        -- height = 20,
        style = "Search",
        children = {
            Title({ page = page }),
            Items(),
        },
    })
end)

return Nav
