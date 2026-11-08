local m = require("markup")

local LABEL_WIDTH = 10

--- A labelled value, which wraps beside its label. The cursor goes past the
--- label, to the value.
---@param props { label: string, children: any }
return m.component(function(props)
	return m.flex({
		m.block({ width = LABEL_WIDTH, shrink = 0, snap = false, m.inline(props.label, "leetcode_muted") }),
		m.block({ grow = 1, shrink = 1, children = props.children }),
	})
end)
