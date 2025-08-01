local Result = require("leetcode.problem.console.result")
local Testcase = require("leetcode.problem.console.testcase")
local Runner = require("leetcode.problem.runner")

---@class leet.problem.console
---@field result leet.problem.console.result
---@field testcase leet.problem.console.testcase
local M = Markup.object()

---@param problem leet.problem
function M:new(problem)
	self.problem = problem

	self.result = Result(self)
	self.testcase = Testcase(self)

	self.layout = Markup.layout({
		wins = {
			["result"] = self.result.win,
			["testcase"] = self.testcase.win,
		},
		show = false,
		layout = {
			box = "horizontal",
			focusable = true,
			position = "bottom",
			height = 0.3,
			{ win = "testcase", width = 0.4 },
			{ win = "result" },
		},
	})
end

function M:run(submit)
	local range = self.problem:editor_section_range("code")
	if not range:is_valid_or_log() then
		return
	end

	if Leet.config.user.console.open_on_runcode then
		self.layout:show()
	end

	self.result.win:focus()

	Runner.run(self.problem, submit)
end

function M:snapshot(id, res)

end

return M
