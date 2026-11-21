local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")

---@param props { width: integer }
return m.component(function(props)
	return m.block({
		-- The width of the box, padding included.
		width = props.width - 4,
		style = "leetcode_surface",
		padding = { 1, 2 },
		kit.Loading(i18n.signing_in),
	})
end)
