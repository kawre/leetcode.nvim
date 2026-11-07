local m = require("markup")

--- Tiles below each other. Their edges are the space between them.
return m.component(function(props)
    return m.vflex({ children = props.children })
end)
