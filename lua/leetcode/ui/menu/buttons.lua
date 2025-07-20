local markup = require("markup")

return markup.Component(function(props)
    return markup.vflex({
        spacing = 1,
        -- horizontal = true,

        markup.block(props.children, "Cursor"),
        -- children = props.children,
    })
end)
