local m = require("markup")

return m.component(function()
	return m.block({
		padding = { 0, 3 },
		m.inline("The judge failed, not your code. Try running it again.", "leetcode_muted"),
	})
end)
