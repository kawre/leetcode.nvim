local markup = require("markup")
local Title = require("leetcode.ui.menu.title")
local log = require("leetcode.logger")

return markup.Component(function(self)
    local page = self.props.page
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
