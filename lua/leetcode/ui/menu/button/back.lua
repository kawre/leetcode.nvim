local Button = require("leetcode.ui.menu.button")
local m = require("markup")

return m.component(function(props)
    local page = props.page

    return Button({
        icon = "",
        title = "Back",
        desc = "Return to the menu",
        lhs = "q",
        page = page,
    })
end)
