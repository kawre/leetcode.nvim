local markup = require("markup")
local log = require("leetcode.logger")
local Title = require("leetcode.ui.menu.title")

local Nav = markup.Component(function(props)
    local page = props.page
    local Items = require("leetcode.ui.menu.nav." .. page)

    return markup.Flex({
        spacing = 1,
        align = "center",
        children = {
            Title({ page = page }),
            Items(),
        },
    })
end)

return Nav
