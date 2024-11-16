local markup = require("markup")

return markup.Component(function(self)
    return markup.Flex({
        markup.Inline("DESCRIPTION"),
    })
end)
