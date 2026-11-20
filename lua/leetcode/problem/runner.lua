local interpreter = require("leetcode.api.interpreter")

---@class leet.problem.runner
---@field question lc.ui.Question
local M = Markup.singleton()
M.running = false

---@param problem leet.problem
function M.run(problem, submit)
	if M.running then
		return Markup.log.warn("Runner is busy")
	end

	local function _run()
		M.running = true

		local body = {
			lang = problem.lang,
			typed_code = problem:editor_submit_lines(submit),
			question_id = problem.problem.id,
			data_input = not submit and problem.console.testcase:content(),
		}
		Leet.logger.debug("body: " .. vim.inspect(body))

		local console = problem.console
		console.result:judging(submit)

		-- The console shows the judge at work and what it decided. With it
		-- closed, one notification says how the run ended.
		local function notify(msg, lvl)
			if not console:is_open() then
				Leet.logger.log(msg, lvl)
			end
		end

		local function callback(item, state, err)
			if err or item then
				M.running = false
			end

			if item then
				console.result:handle(item)
				notify(
					item._.title or item.status_msg,
					item._.success and vim.log.levels.INFO or vim.log.levels.ERROR
				)
			elseif state then
				console.result:set_state(state)
			elseif err then
				console.result:failed(err)
				notify(err.msg or "Something went wrong", err.lvl or vim.log.levels.ERROR)
			end
		end

		interpreter.run(submit, problem, body, callback)
	end

	vim.schedule(_run)
end

return M
