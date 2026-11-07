local m = require("markup")
local diff = require("leetcode.ui.problem.result.diff")
local Field = require("leetcode.ui.problem.result.field")
local Stdout = require("leetcode.ui.problem.result.stdout")
local Input = require("leetcode.ui.problem.result.input")

local function spans(runs, group)
	return vim.tbl_map(function(run)
		return m.inline(run[1], run[2] and group or nil)
	end, runs)
end

---@param props { input: string[], output: string, expected: string, stdout?: string, params?: table[] }
local Case = m.component(function(props)
	local output = props.output or ""
	local expected = props.expected or ""
	local got, wanted = diff.split(output, expected)

	return m.block({
		spacing = 1,
		Input({ input = props.input, params = props.params }),
		Field({ label = "Output", children = m.block(spans(got, "leetcode_diff_delete")) }),
		Field({ label = "Expected", children = m.block(spans(wanted, "leetcode_diff_add")) }),
		Stdout({ stdout = props.stdout }),
	})
end)

return Case
