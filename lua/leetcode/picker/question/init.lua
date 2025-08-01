local config = require("leetcode.config")
local log = require("leetcode.logger")
local ui_utils = require("leetcode-ui.utils")
local utils = require("leetcode.util")
local Problem = require("leetcode.problem")
local Picker = require("leetcode.picker")

---@class leet.Picker.Question: leet.Picker
local P = {}

P.width = 100
P.height = 0.6

---@param items leet.cache.problem[]
---@param opts table<string, string[]>
---
---@return leet.cache.problem[]
function P.filter(items, opts)
	if vim.tbl_isempty(opts or {}) then
		return items
	end

	---@param q leet.cache.problem
	return vim.tbl_filter(function(q)
		local diff_flag = true
		if opts.difficulty and not vim.tbl_contains(opts.difficulty, q.difficulty:lower()) then
			diff_flag = false
		end

		local status_flag = true
		if opts.status and not vim.tbl_contains(opts.status, q.status) then
			status_flag = false
		end

		return diff_flag and status_flag
	end, items)
end

---@param content leet.cache.problem[]
---@param opts table<string, string[]>
---
---@return { entry: any, value: leet.cache.problem }[]
function P.items(content, opts)
	local filtered = P.filter(content, opts)
	return vim.tbl_map(function(item)
		return { entry = P.entry(item), value = item }
	end, filtered)
end

---@param question leet.cache.problem
local function display_user_status(question)
	if question.paid_only then
		return config.auth.is_premium and config.icons.hl.unlock or config.icons.hl.lock
	end

	return config.icons.hl.status[question.status] or { " " }
end

---@param question leet.cache.problem
local function display_difficulty(question)
	local hl = ui_utils.diff_to_hl(question.difficulty)
	return { config.icons.square, hl }
end

---@param question leet.cache.problem
local function display_question(question)
	local index = { question.frontend_id .. ".", "leetcode_normal" }
	local title = { utils.translate(question.title, question.title_cn) }
	local ac_rate = { ("(%.1f%%)"):format(question.ac_rate), "leetcode_ref" }

	return unpack({ index, title, ac_rate })
end

function P.entry(item)
	return {
		display_user_status(item),
		display_difficulty(item),
		display_question(item),
	}
end

---@param item leet.cache.problem
function P.ordinal(item)
	return ("%s. %s %s %s"):format(
		tostring(item.frontend_id),
		item.title,
		item.title_cn,
		item.title_slug
	)
end

function P.select(selection, close)
	local did_open = Leet.cmd.open(selection)

	if did_open and close then
		close()
	end
end

return P
