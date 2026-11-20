local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")
local t = require("leetcode.translator")

--- Why LeetCode did not take the run, and what to do about it.
---@param props { err: lc.err, too_soon: boolean }
return m.component(function(props)
	local message = props.err.msg and t(props.err.msg) or i18n.something_went_wrong

	return m.block({
		padding = { 1, 3, 0, 3 },
		snap = false,
		m.block({ message, style = "leetcode_muted" }),
		props.too_soon and m.block({
			margin_top = 1,
			kit.Sentence(i18n.too_soon_hint, kit.Key(":Leet run")),
		}),
	})
end)
