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

end

--- Splits cannot be hidden, so the layout is rebuilt each time it opens.
function M:open()
	if self:is_open() then
		return
	end

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
	self.layout:show()
end

---@return boolean
function M:is_open()
	return self.layout ~= nil and self.layout:valid()
end

function M:run(submit)
	local range = self.problem:editor_section_range("code")
	if not range:is_valid_or_log() then
		return
	end

	if Leet.config.user.console.open_on_runcode then
		self:open()
	end

	self.result.win:focus()

	Runner.run(self.problem, submit)
end

function M:toggle()
	if self:is_open() then
		self:close()
	else
		self:open()
	end
end

function M:close()
	if self:is_open() then
		-- Plain closing keeps the keymaps and events of the windows.
		self.result.win:close()
		self.testcase.win:close()
		self.layout:close({ wins = false })
	end
end

function M:snapshot(id, data)
	self.testcase:snapshot(id, data)
end

return M
