local m = require("markup")
local kit = require("leetcode.ui.kit")
local Verdict = require("leetcode.ui.problem.result.verdict")
local Runtime = require("leetcode.ui.problem.result.runtime")
local SubmissionError = require("leetcode.ui.problem.result.submission-error")
local LimitExceed = require("leetcode.ui.problem.result.limit-exceeded")
local RuntimeError = require("leetcode.ui.problem.result.runtime.error")
local InternalError = require("leetcode.ui.problem.result.internal-error")
local CompileError = require("leetcode.ui.problem.result.compile-error")

local function number(value)
	return value ~= vim.NIL and tonumber(value) or nil
end

--- How far a submission got, or how long a run took.
local function Detail(item)
	local correct, total = number(item.total_correct), number(item.total_testcases)

	if item._.submission and not item._.success and correct and total and total > 0 then
		return m.inline({
			kit.Bar({
				width = 14,
				style = "leetcode_bar_error",
				value = function()
					return correct / total
				end,
			}),
			m.inline((" %d/%d passed"):format(correct, total)),
		})
	end

	if item._.submission and item._.success then
		local lang = Leet.util.get_lang_by_name(item.pretty_lang)
		return lang and m.inline(lang.icon .. " " .. lang.lang)
	end

	return item.status_runtime and m.inline(item.status_runtime)
end

---@param sc integer
---@return string
local function kind_of(item, sc)
	if sc == 10 then
		return item._.success and "ok" or "error"
	end
	return (sc == 12 or sc == 13 or sc == 14) and "warn" or "error"
end

---@param props { item: lc.interpreter_response, console: leet.problem.console }
local App = m.component(function(props)
	local item = props.item ---@type any
	local console = props.console
	local sc = item.status_code

	local body
	if sc == 10 then
		body = Runtime({ item = item, console = console })
	elseif sc == 11 then
		body = SubmissionError({ item = item })
	elseif sc == 12 or sc == 13 or sc == 14 then
		body = LimitExceed({ item = item })
	elseif sc == 15 then
		body = RuntimeError({ item = item })
	elseif sc == 16 then
		body = InternalError({ item = item })
	elseif sc == 20 then
		body = CompileError({ item = item })
	else
		body = m.block("unknown runner status code: " .. sc)
	end

	return m.block({
		Verdict({ title = item._.title, kind = kind_of(item, sc), detail = Detail(item) }),
		body,
	})
end)

return App
