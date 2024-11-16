local markup = require("markup")
local log = require("leetcode.logger")

return markup.Component(function(self)
    return markup.Flex({
        spacing = 1,
        children = self.props,
    })
end)
