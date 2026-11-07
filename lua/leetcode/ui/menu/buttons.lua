local m = require("markup")

return m.component(function(props)
    return m.vflex({ children = props.children })
end)
