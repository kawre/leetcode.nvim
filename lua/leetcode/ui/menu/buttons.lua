local markup = require("markup")

return markup.Component(function(props)
    return markup.vflex({
        spacing = 1,
        children = props.children,
    })
end)
