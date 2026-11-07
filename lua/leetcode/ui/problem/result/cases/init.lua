local m = require("markup")
local kit = require("leetcode.ui.kit")
local Case = require("leetcode.ui.problem.result.cases.case")

---@param props { item: lc.runtime, console: leet.problem.console }
local Cases = m.component(function(props)
	local active = m.signal(1)

	local item = props.item
	local console = props.console

	local total = item.total_testcases ~= vim.NIL and item.total_testcases or 0
	local testcases = console.testcase:by_id(item.submission_id)
	local compare = type(item.compare_result) == "string" and item.compare_result or ""

	for i = 1, total do
		m.use_key(tostring(i), function()
			active(i)
		end)
	end

	local cases = Markup.list(testcases):map(function(case, i)
		return Case({
			input = case,
			output = item.code_answer[i],
			expected = item.expected_code_answer[i],
			stdout = item.std_output_list[i],
			params = item._.params,
		})
	end)

	local tabs = Markup.list(testcases):map(function(_, i)
		local passed = compare:sub(i, i)
		local failed = passed == "0"
		local kind = failed and "error" or "ok"

		return m.inline({
			on_press = function()
				active(i)
			end,
			style = function()
				return ("leetcode_tab_%s%s"):format(kind, active() == i and "_active" or "")
			end,
			(" %s Case %d "):format(failed and kit.icons.cross or kit.icons.check, i),
		})
	end)

	return m.block({
		padding = { 0, 3 },
		m.block({ margin_bottom = 1, spacing = 1, m.inline({ spacing = 1, tabs }) }),
		function()
			return cases[active()]
		end,
	})
end)

return Cases
