local markup = require("markup")

return markup.Component({
    render = function()
        return markup.Inline("loading...")
    end,
})
