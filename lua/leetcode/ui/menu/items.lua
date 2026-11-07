local m = require("markup")

--- Items with a line between them.
return m.component(function(props)
    return m.vflex({ spacing = 1, children = props.children })
end)
