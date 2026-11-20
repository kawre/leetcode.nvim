local m = require("markup")

return m.component(function(props)
	return m.vflex({ spacing = 1, children = props.children })
end)
