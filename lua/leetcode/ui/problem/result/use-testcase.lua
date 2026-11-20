local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")

--- A press, and its key, that makes the input a submission failed on one of
--- the testcases, to run again and work on. It goes to the testcase tab to
--- show it there.
---@param props { console: leet.problem.console, input: string }
return m.component(function(props)
	local console = props.console
	local hovered = m.signal(false)
	local key = require("leetcode.config").user.keys.use_testcase

	local function use()
		console.testcase:use(props.input)
		console.tab("testcase")
	end

	if key and key ~= "" then
		m.use_key(key, use)
	end

	return m.block({
		white_space = "nowrap",
		m.inline({
			click = "double",
			on_press = use,
			on_hover = hovered,
			style = function()
				return hovered() and "leetcode_console_case_active_hover"
					or "leetcode_console_case_active"
			end,
			(" %s %s "):format(kit.icons.add, i18n.use_testcase),
		}),
		key and key ~= "" and m.inline({ "  " .. key, style = "leetcode_key", snap = false }),
	})
end)
