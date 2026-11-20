local m = require("markup")
local UseTestcase = require("leetcode.ui.problem.result.use-testcase")
local i18n = require("leetcode.i18n")
local Stdout = require("leetcode.ui.problem.result.stdout")
local Input = require("leetcode.ui.problem.result.input")

--- A case LeetCode would not run, with a way to it.
---@param props { console: leet.problem.console, index: integer }
local InvalidCase = m.component(function(props)
	local console = props.console
	local hovered = m.signal(false)

	local function go()
		console.testcase:select(props.index)
		console.tab("testcase")
		if console:is_open() then
			console.win:focus()
		end
	end
	m.use_key("e", go)

	return m.block({
		m.block({ i18n.invalid_case(props.index), style = "leetcode_muted" }),
		m.block({
			margin_top = 1,
			m.inline({
				click = "double",
				on_press = go,
				on_hover = hovered,
				style = function()
					return hovered() and "leetcode_console_case_active_hover"
						or "leetcode_console_case_active"
				end,
				(" \u{f03eb} %s "):format(i18n.edit_case(props.index)),
			}),
			m.inline({ "  e", style = "leetcode_key", snap = false }),
		}),
	})
end)

---@param props { item: lc.runtime_error, console?: leet.problem.console }
local RuntimeError = m.component(function(props)
	local item = props.item
	local invalid = item.invalid_testcase == true
		and type(item.case_idx) == "number"
		and props.console

	return m.block({
		padding = { 0, 3 },
		spacing = 1,
		m.block({
			style = "leetcode_error",
			children = Markup.list(vim.split(item.full_runtime_error, "\n")):map(function(line)
				return m.block(line)
			end),
		}),
		invalid and InvalidCase({ console = props.console, index = item.case_idx + 1 }),
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
				or (item.std_output_list and item.std_output_list[#item.std_output_list]),
		}),
	})
end)

return RuntimeError
