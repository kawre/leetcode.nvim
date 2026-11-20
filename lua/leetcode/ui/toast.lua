--- A loader in the corner of the editor, for work that nothing on screen
--- started, such as opening a question from a picker.

local m = require("markup")
local kit = require("leetcode.ui.kit")

---@param text string
---@return fun() close
return function(text)
	local width = vim.api.nvim_strwidth(text) + 4
	local win = Markup.window({
		position = "float",
		relative = "editor",
		row = function()
			return vim.o.lines - vim.o.cmdheight - 4
		end,
		col = function()
			return vim.o.columns - width - 3
		end,
		width = width,
		height = 1,
		border = "rounded",
		backdrop = false,
		enter = false,
		focusable = false,
		zindex = 60,
		show = true,
		minimal = true,
		bo = { filetype = "leetcode.toast" },
	})
	local view = Markup.view(win)
	view:render(m.block({ padding = { 0, 1 }, white_space = "nowrap", kit.Loading(text) }))

	local closed = false
	return function()
		if closed then
			return
		end
		closed = true
		view:destroy()
		win:close()
	end
end
