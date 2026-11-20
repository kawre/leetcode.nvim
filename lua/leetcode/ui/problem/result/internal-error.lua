local m = require("markup")
local i18n = require("leetcode.i18n")

return m.component(function()
	return m.block({
		padding = { 0, 3 },
		m.inline(i18n.judge_failed, "leetcode_muted"),
	})
end)
