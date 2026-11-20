local m = require("markup")
local i18n = require("leetcode.i18n")
local Input = require("leetcode.ui.problem.result.input")
local Stdout = require("leetcode.ui.problem.result.stdout")
local UseTestcase = require("leetcode.ui.problem.result.use-testcase")

---@param props { item: lc.limit_exceeded_error, console?: leet.problem.console }
local LimitExceed = m.component(function(props)
	local item = props.item

	return m.block({
		padding = { 0, 3 },
		spacing = 1,
		item._.submission and Input({
			title = i18n.last_input,
			input = vim.split(item.last_testcase, "\n"),
			params = item._.params,
		}),
		item._.submission
			and props.console
			and UseTestcase({ console = props.console, input = item.last_testcase }),
		Stdout({
			stdout = item._.submission and item.std_output
				or item.std_output_list[#item.std_output_list],
		}),
	})
end)

return LimitExceed
