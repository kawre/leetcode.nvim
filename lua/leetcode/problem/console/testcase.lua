local m = require("markup")
local reactive = require("markup.reactive")

local api = vim.api

--- The testcases a run tries: a list of cases, each the value of every
--- parameter as it is typed into LeetCode. The console's testcase tab shows and
--- edits them.
---@class leet.problem.console.testcase
---@field console leet.problem.console
---@field cases markup.reactive.signal string[][]
---@field selected markup.reactive.signal integer the case shown
local M = Markup.object()

---@param console leet.problem.console
function M:new(console)
	self.console = console
	self.testcases = {} ---@type table<string, string> what each run tried, by its id

	local meta = console.problem.problem.meta_data or {}
	self.params = type(meta.params) == "table" and meta.params or {}

	local list = console.problem.problem.testcase_list or {}
	self.defaults = {}
	for i, case in ipairs(list) do
		self.defaults[i] = vim.split(case, "\n", { trimempty = true })
	end
	self.testcase_len = #self.params > 0 and #self.params or #(self.defaults[1] or { "" })

	self.cases = m.signal(vim.deepcopy(self.defaults))
	self.selected = m.signal(1)
	self.fields = {} ---@type table<integer, function> the press of each field shown, by parameter
end

--- The names of the parameters, or numbers where LeetCode gives none.
---@return string[]
function M:names()
	local names = {}
	for i = 1, self.testcase_len do
		local param = self.params[i]
		names[i] = param and param.name or ("input %d"):format(i)
	end
	return names
end

--- Every case one after another, as LeetCode reads them.
---@return string
function M:content()
	local lines = {}
	for _, case in ipairs(reactive.untrack(self.cases)) do
		for i = 1, self.testcase_len do
			local value = case[i] or ""
			if value ~= "" then
				lines[#lines + 1] = value
			end
		end
	end
	return table.concat(lines, "\n")
end

---@param index integer
function M:select(index)
	local count = #reactive.untrack(self.cases)
	self.selected(math.max(math.min(index, count), 1))
end

--- A new case, with the values of the one shown to start from, as LeetCode does.
function M:add()
	local cases = vim.deepcopy(reactive.untrack(self.cases))
	local from = cases[reactive.untrack(self.selected)] or {}
	cases[#cases + 1] = vim.deepcopy(from)
	self.cases(cases)
	self.selected(#cases)
end

--- Removes a case, keeping at least one.
---@param index? integer the one shown by default
function M:remove(index)
	local cases = vim.deepcopy(reactive.untrack(self.cases))
	if #cases <= 1 then
		return
	end
	index = index or reactive.untrack(self.selected)
	table.remove(cases, index)
	self.cases(cases)
	self:select(math.min(reactive.untrack(self.selected), #cases))
end

--- Back to the cases of the problem.
function M:reset()
	self.cases(vim.deepcopy(self.defaults))
	self.selected(1)
end

---@param case integer
---@param param integer
---@param value string
function M:set(case, param, value)
	local cases = vim.deepcopy(reactive.untrack(self.cases))
	if not cases[case] then
		return
	end
	cases[case][param] = value
	self.cases(cases)
end

--- Types a value in a line over its field, which the cursor is on.
---@param param integer
function M:edit(param)
	local console = self.console
	local win = console.win.win
	if not (win and api.nvim_win_is_valid(win)) then
		return
	end

	local case = reactive.untrack(self.selected)
	local value = (reactive.untrack(self.cases)[case] or {})[param] or ""

	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	api.nvim_buf_set_lines(buf, 0, -1, false, { value })

	local where = self:field_at(param)
	if not where then
		return
	end
	local row, col = where[1], where[2]
	local input = api.nvim_open_win(buf, true, {
		relative = "win",
		win = win,
		row = row,
		col = col,
		width = math.max(api.nvim_win_get_width(win) - col - 3, 10),
		height = 1,
		style = "minimal",
		zindex = 60,
	})
	vim.wo[input].winhighlight = "NormalFloat:leetcode_input_focus"
	self.editing = { case = case, param = param, win = input }
	console.typing(param)

	--- Neovim holds back TextChangedI while keys are queued, so it is read
	--- again before leaving.
	local function sync()
		if api.nvim_buf_is_valid(buf) then
			self:set(case, param, api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
		end
	end

	api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, { buffer = buf, callback = sync })

	local done = false
	local function leave()
		if done then
			return
		end
		done = true
		sync()
		vim.cmd.stopinsert()
		self.editing = nil
		console.typing(nil)
		if api.nvim_win_is_valid(input) then
			api.nvim_win_close(input, true)
		end
		if api.nvim_win_is_valid(win) then
			api.nvim_set_current_win(win)
		end
		reactive.flush()
	end

	for _, mode in ipairs({ "i", "n" }) do
		for _, lhs in ipairs({ "<CR>", "<Esc>" }) do
			vim.keymap.set(mode, lhs, leave, { buffer = buf, nowait = true })
		end
	end
	vim.keymap.set("n", "q", leave, { buffer = buf, nowait = true })
	api.nvim_create_autocmd(
		"WinLeave",
		{ buffer = buf, once = true, callback = vim.schedule_wrap(leave) }
	)

	vim.cmd.startinsert({ bang = true })
end

--- Where the text of a parameter's field starts in the console's window, as a
--- row and a column from zero, or nil while it is not on screen.
---@param param integer
---@return integer[]?
function M:field_at(param)
	local view, press = self.console.view, self.fields[param]
	if not press then
		return
	end
	for id, handler in pairs(view.handlers) do
		if handler == press then
			local ok, node = pcall(view.engine.describe, view.engine, id)
			if not ok or not node.x then
				return
			end
			local top = vim.fn.line("w0", self.console.win.win) - 1
			local row = node.y - top
			if row < 0 or row >= vim.api.nvim_win_get_height(self.console.win.win) then
				return
			end
			-- Past the bar at the start of the field.
			return { row, node.x + 2 }
		end
	end
end

function M:snapshot(id, data)
	if not data.test_case then
		return
	end
	self.testcases[id] = data.test_case
end

---@return string[][]
function M:by_id(id)
	local testcases = {} ---@type string[][]

	local i, n = 0, self.testcase_len
	for case in vim.gsplit(self.testcases[id] or "", "\n") do
		local j = math.floor(i / n) + 1

		if not testcases[j] then
			testcases[j] = {}
		end
		table.insert(testcases[j], case)

		i = i + 1
	end

	return testcases
end

return M
