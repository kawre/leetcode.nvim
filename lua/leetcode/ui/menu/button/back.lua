local Button = require("leetcode.ui.menu.button")
local markup = require("markup")

return markup.Component({
    render = function(self)
        local page = self.props

        return Button({
            icon = "",
            title = "Back",
            key = "q",
            page = page,
        })
    end,
})
