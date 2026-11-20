local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")

return m.component(function()
	return m.block({ padding = { 0, 1 }, kit.Loading(i18n.signing_in) })
end)
