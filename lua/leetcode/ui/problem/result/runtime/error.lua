local m = require("markup")
local Stdout = require("leetcode.ui.problem.result.stdout")
local Input = require("leetcode.ui.problem.result.input")

---@param props { item: lc.runtime_error }
local RuntimeError = m.component(function(props)
	local item = props.item

	return m.block({
		padding = { 0, 3 },
		spacing = 1,
		m.block({
			style = "leetcode_error",
			children = Markup.list(vim.split(item.full_runtime_error, "\n")):map(function(line)
				return m.block(line)
			end),
		}),
		item._.submission and Input({
			title = "Last input",
			input = vim.split(item.last_testcase, "\n"),
			params = item._.params,
		}),
		Stdout({
			stdout = item._.submission and item.std_output
				or (item.std_output_list and item.std_output_list[#item.std_output_list]),
		}),
	})
end)

return RuntimeError
