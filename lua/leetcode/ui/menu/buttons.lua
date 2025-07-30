local markup = require("markup")

return markup.component(function(props)
    return markup.vflex({
        spacing = 1,
        width = 50,
        children = props.children,
    })
end)
