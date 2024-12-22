local markup = require("markup")

return markup.Component(function(props)
    return markup.Flex({
        spacing = 1,
        -- horizontal = true,
        children = props.children,
    })
end)
