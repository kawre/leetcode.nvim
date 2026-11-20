local m = require("markup")
local Input = require("leetcode.ui.problem.result.input")
local Stdout = require("leetcode.ui.problem.result.stdout")

---@param props { item: lc.limit_exceeded_error }
local LimitExceed = m.component(function(props)
	local item = props.item

	return m.block({
		padding = { 0, 3 },
		spacing = 1,
		item._.submission and Input({
			title = "Last input",
			input = vim.split(item.last_testcase, "\n"),
			params = item._.params,
		}),
		Stdout({
			stdout = item._.submission and item.std_output
				or item.std_output_list[#item.std_output_list],
		}),
	})
end)

return LimitExceed
