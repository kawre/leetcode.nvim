local markup = require("markup")

return markup.Component(function(self)
    return markup.Flex({
        spacing = 1,
        children = self.props,
    })
end)
