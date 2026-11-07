local m = require("markup")
local Result = require("leetcode.problem.console.result")
local Testcase = require("leetcode.problem.console.testcase")
local Runner = require("leetcode.problem.runner")
local Panel = require("leetcode.ui.problem.console")

--- How much of the editor the console takes, below it.
local HEIGHT = 0.35

--- A split below the editor with two tabs: the testcases to run, and what the
--- last run or submission came to.
---@class leet.problem.console
---@field problem leet.problem
---@field win markup.window
---@field view markup.view
---@field result leet.problem.console.result
---@field testcase leet.problem.console.testcase
---@field tab markup.reactive.signal "testcase"|"result"
---@field typing markup.reactive.signal integer? the parameter being typed
local M = Markup.object()

---@param problem leet.problem
function M:new(problem)
	self.problem = problem
	self.tab = m.signal("testcase")
	self.typing = m.signal(nil)

	self.win = Markup.window({
		position = "bottom",
		relative = "win",
		win = problem.win,
		height = HEIGHT,
		enter = false,
		show = false,
		focusable = true,
		minimal = true,
		bo = { filetype = Leet.config.name },
		wo = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
	})
	self.view = Markup.view(self.win, { snap = true, hide_cursor = true })

	self.testcase = Testcase(self)
	self.result = Result(self)

	self.view:render(Panel({ console = self }))
end

function M:open()
	if self:is_open() then
		return
	end
	self.win:show()
end

---@return boolean
function M:is_open()
	return self.win:valid() == true
end

--- Opens the console on a tab.
---@param tab "testcase"|"result"
function M:show(tab)
	self.tab(tab)
	self:open()
end

function M:run(submit)
	local range = self.problem:editor_section_range("code")
	if not range:is_valid_or_log() then
		return
	end

	self.tab("result")
	if Leet.config.user.console.open_on_runcode then
		self:open()
	end
	if self:is_open() then
		self.win:focus()
	end

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
		self.win:close()
	end
end

function M:snapshot(id, data)
	self.testcase:snapshot(id, data)
end

return M
