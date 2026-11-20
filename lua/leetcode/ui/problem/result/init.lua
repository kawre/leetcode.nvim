local m = require("markup")
local Runtime = require("leetcode.ui.problem.result.runtime")
local SubmissionError = require("leetcode.ui.problem.result.submission-error")
local LimitExceed = require("leetcode.ui.problem.result.limit-exceeded")
local RuntimeError = require("leetcode.ui.problem.result.runtime.error")
local InternalError = require("leetcode.ui.problem.result.internal-error")
local CompileError = require("leetcode.ui.problem.result.compile-error")

---@param props { item: lc.interpreter_response, console: leet.problem.console }
local App = m.component(function(props)
	local item = props.item ---@type any
	local console = props.console
	local sc = item.status_code

	local body
	if sc == 10 then
		body = Runtime({ item = item, console = console })
	elseif sc == 11 then
		body = SubmissionError({ item = item, console = console })
	elseif sc == 12 or sc == 13 or sc == 14 then
		body = LimitExceed({ item = item, console = console })
	elseif sc == 15 then
		body = RuntimeError({ item = item, console = console })
	elseif sc == 16 then
		body = InternalError({ item = item })
	elseif sc == 20 then
		body = CompileError({ item = item })
	else
		body = m.block("unknown runner status code: " .. sc)
	end

	-- What it came to shows in the console's header, so the body starts here.
	return m.block({ padding_top = 1, body })
end)

return App
