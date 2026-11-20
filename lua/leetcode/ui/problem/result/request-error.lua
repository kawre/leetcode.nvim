local m = require("markup")
local t = require("leetcode.translator")

--- Why LeetCode did not take the run, and what to do about it.
---@param props { err: lc.err, too_soon: boolean }
return m.component(function(props)
	local message = props.err.msg or "Something went wrong"

	return m.block({
		padding = { 1, 3, 0, 3 },
		snap = false,
		m.block({ t(message), style = "leetcode_muted" }),
		props.too_soon and m.block({
			margin_top = 1,
			m.inline(
				"LeetCode takes a run every few seconds. Wait a moment, then ",
				"leetcode_muted"
			),
			m.inline(":Leet run", "leetcode_key"),
			m.inline(" again.", "leetcode_muted"),
		}),
	})
end)
