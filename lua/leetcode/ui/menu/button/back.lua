local Button = require("leetcode.ui.menu.button")
local m = require("markup")

return m.component(function(props)
    local page = props.page

    return Button({
        icon = "",
        title = "Back",
        lhs = "q",
        page = page,
    })
end)
