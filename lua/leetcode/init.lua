---@module 'markup'

local config = require("leetcode.config")

---@class leet
local M = {}

---@class leet.global
---@field active_problems leet.problem[]
---@field api leet.api
---@field cache leet.cache
---@field cmd leet.cmd
---@field problem leet.problem
---@field guard leet.guard
---@field util leet.util
---@field config leet.config
_G.Leet = { ctx = {}, active_problems = {} }

local function log_failed_to_init()
	local log = require("leetcode.logger")
	log.warn("Failed to initialize: `neovim` contains listed buffers")
end

local function log_buf_not_empty(bufname)
	local log = require("leetcode.logger")
	if bufname and bufname ~= "" then
		log.warn(("Failed to initialize: `%s` is not an empty buffer"):format(bufname))
	else
		log.warn("Failed to initialize: not an empty buffer")
	end
end

local function buf_is_empty(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
	return not (#lines > 1 or (#lines == 1 and lines[1]:len() > 0))
end

---@param on_vimenter boolean
---
---@return boolean, boolean? (skip, standalone)
function M.should_skip(on_vimenter)
	if on_vimenter then
		if vim.fn.argc(-1) ~= 1 then
			return true
		end

		local usr_arg, arg = config.user.arg, vim.fn.argv(0, -1)
		if usr_arg ~= arg then
			return true
		end

		if not buf_is_empty(0) then
			log_buf_not_empty(usr_arg)
			return true
		end

		return false, true
	else
		local listed_bufs = vim.tbl_filter(function(info)
			return info.listed == 1
		end, vim.fn.getbufinfo())

		if #listed_bufs == 0 then
			return false, true
		elseif vim.fn.argc(-1) == 0 and #listed_bufs == 1 then
			local buf = listed_bufs[1]

			if vim.api.nvim_get_current_buf() ~= buf.bufnr then
				if config.plugins.non_standalone then
					return false, false
				else
					log_failed_to_init()
					return true
				end
			end

			vim.schedule(function()
				if buf.changed == 1 then
					vim.api.nvim_buf_delete(buf.bufnr, { force = true })
				end
			end)

			return false, true
		elseif #listed_bufs >= 1 then
			if config.plugins.non_standalone then
				return false, false
			else
				log_failed_to_init()
				return true
			end
		end
	end
end

function M.setup_cmds()
	require("leetcode.cmd").setup()
end

---@param on_vimenter boolean
function M.start(on_vimenter)
	local skip = M.should_skip(on_vimenter)
	if skip then
		return false
	end

	config.setup()

	_G.Leet = setmetatable({
		ctx = {},
		active_problems = {},
	}, {
		__index = function(t, k)
			t[k] = require("leetcode." .. k)
			return rawget(t, k)
		end,
	})

	vim.api.nvim_set_current_dir(config.storage.home:absolute())

	M.setup_cmds()

	local theme = require("leetcode.theme")
	theme.setup()

	if not on_vimenter then
		vim.cmd.enew()
	end

	local menu = require("leetcode.ui.menu")
	menu.win.buf = vim.api.nvim_get_current_buf()
	menu.win:show()
	menu:render()

	local utils = require("leetcode.util")
	utils.exec_hooks("enter")

	return true
end

function M.stop()
	vim.cmd("qa!")
end

---@param cfg? lc.UserConfig
function M.setup(cfg)
	config.apply(cfg or {})

	vim.api.nvim_create_user_command("Leet", require("leetcode.cmd").start_with_cmd, {
		bar = true,
		bang = true,
		desc = "Open leetcode.nvim",
	})

	local group_id = vim.api.nvim_create_augroup("leetcode_start", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group_id,
		pattern = "*",
		nested = true,
		callback = function()
			M.start(true)
		end,
	})
end

return M
