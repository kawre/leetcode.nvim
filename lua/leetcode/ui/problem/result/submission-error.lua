local m = require("markup")
local Case = require("leetcode.ui.problem.result.cases.case")
local UseTestcase = require("leetcode.ui.problem.result.use-testcase")

---@param props { item: lc.submission, console?: leet.problem.console }
local SubmissionError = m.component(function(props)
	local item = props.item

	return m.block({
		padding = { 0, 3 },
		Case({
			input = vim.split(item.input, "\n"),
			output = item.code_output,
			expected = item.expected_output,
			stdout = item.std_output,
			params = item._.params,
			after = props.console and UseTestcase({ console = props.console, input = item.input }),
		}),
	})
end)

return SubmissionError
