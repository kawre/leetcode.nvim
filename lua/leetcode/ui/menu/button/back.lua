local Button = require("leetcode.ui.menu.button")
local markup = require("markup")

return markup.Component(function(props)
    local page = props.page

    return Button({
        icon = "",
        title = "Back",
        key = "q",
        page = page,
    })
end)
