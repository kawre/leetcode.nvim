local m = require("markup")
local kit = require("leetcode.ui.kit")

return m.component(function()
	return m.block({ padding = { 0, 1 }, kit.Loading("Signing in") })
end)
