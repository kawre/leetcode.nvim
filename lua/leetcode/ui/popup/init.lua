local config = require("leetcode.config")

---@class leet.ui.popup.opts
---@field title string
---@field width number
---@field height number
---@field content fun(): any called each time the popup opens

---@class leet.ui.popup
---@field opts leet.ui.popup.opts
---@field win? markup.window
---@field view? markup.view
---@overload fun(opts: leet.ui.popup.opts): leet.ui.popup
local M = Markup.object()

---@param opts leet.ui.popup.opts
function M:new(opts)
	self.opts = opts
end

function M:is_open()
	return self.win ~= nil and self.win:win_valid()
end

function M:show()
	if self:is_open() then
		return self.win:focus()
	end

	local opts = self.opts
	self.win = Markup.window({
		position = "float",
		relative = "editor",
		width = opts.width,
		height = opts.height,
		border = "rounded",
		title = (" %s "):format(opts.title),
		enter = true,
		minimal = true,
		on_close = function()
			self:destroy()
		end,
	})
	self.view = Markup.view(self.win)

	local keys = config.user.keys
	for _, lhs in ipairs(vim.iter({ keys.toggle }):flatten():totable()) do
		self.win:map("n", lhs, function()
			self:close()
		end)
	end
	for _, lhs in ipairs(vim.iter({ keys.confirm }):flatten():totable()) do
		self.win:map("n", lhs, function()
			self.view:press()
		end)
	end

	self.view:render(opts.content())
end

function M:destroy()
	if self.view then
		self.view:destroy()
		self.view = nil
	end
end

function M:close()
	if self:is_open() then
		self.win:close()
	end
	self:destroy()
end

function M:toggle()
	if self:is_open() then
		self:close()
	else
		self:show()
	end
end

return M
