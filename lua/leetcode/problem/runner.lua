---@module 'plenary'

local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")
local Judge = require("leetcode.logger.spinner.judge")

---@type Path
local leetbody = config.storage.cache:joinpath("body")
leetbody:touch()

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
		Markup.log("body:", body)

		local judge = Judge:init()
		local function callback(item, state, err)
			if err or item then
				M.running = false
			end

			if item then
				if item._.success then
					judge:success(item.status_msg)
				else
					judge:error(item.status_msg)
				end
			elseif state then
				judge:from_state(state)
			elseif err then
				judge:error(err.msg or "Something went wrong")
			end

			if item then
				problem.console.result:handle(item)
			end
		end

		leetbody:write(vim.json.encode(body), "w")
		interpreter.run(submit, problem, leetbody:absolute(), callback)
	end

	vim.schedule(_run)
end

return M
