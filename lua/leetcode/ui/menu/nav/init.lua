local markup = require("markup")
local Title = require("leetcode.ui.menu.title")

return function(page)
    local component = require("leetcode.ui.menu.nav." .. page)

    return markup.Flex({
        spacing = 1,
        align = "center",
        children = {
            Title({ page, page }),
            component(),
        },
    })
end
