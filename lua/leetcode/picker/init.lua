--- Pickers for problems, languages and open problems, built on markup's own, so
--- no picker plugin is needed.

local config = require("leetcode.config")
local log = require("leetcode.logger")
local t = require("leetcode.translator")
local ui = require("leetcode.ui.util")

---@class leet.Picker
local P = {}

--- Keeps the problems that pass `Leet list` options, such as `difficulty=easy`.
---@param problems leet.cache.problem[]
---@param opts? table<string, string[]>
---@return leet.cache.problem[]
function P.filter(problems, opts)
	if vim.tbl_isempty(opts or {}) then
		return problems
	end

	return vim.tbl_filter(function(problem)
		if opts.difficulty and not vim.tbl_contains(opts.difficulty, problem.difficulty:lower()) then
			return false
		end
		if opts.status and not vim.tbl_contains(opts.status, problem.status) then
			return false
		end
		return true
	end, problems)
end

---@param problem leet.cache.problem
---@return markup.picker.item
local function problem_item(problem)
	local status = config.icons.hl.status[problem.status]
	local locked = problem.paid_only and not config.auth.is_premium

	local marker
	if locked then
		marker = { config.icons.lock, "leetcode_medium" }
	else
		marker = status and { status[1], status[2] } or { " " }
	end

	return {
		label = Leet.util.translate(problem.title, problem.title_cn),
		keywords = ("%s %s %s"):format(problem.frontend_id, problem.title_slug, problem.title_cn or ""),
		prefix = {
			marker,
			{ " " .. config.icons.square .. " ", ui.diff_to_hl(problem.difficulty) },
			{ ("%5s. "):format(problem.frontend_id), "leetcode_muted" },
		},
		suffix = { { ("%.1f%%"):format(problem.ac_rate or 0), "leetcode_muted" } },
		value = problem,
	}
end

---@param problems leet.cache.problem[]
---@param opts? table<string, string[]>
function P.question(problems, opts)
	Markup.picker({
		title = t("Select a Question"),
		width = 100,
		height = 20,
		items = vim.tbl_map(problem_item, P.filter(problems, opts)),
		on_select = function(problem)
			Leet.cmd.open(problem)
		end,
	})
end

--- Changes the language of a problem, or hands the choice to `cb`.
---@param problem leet.problem
---@param cb? fun(slug: string)
function P.language(problem, cb)
	local items = {}

	for _, snippet in ipairs(problem.problem.code_snippets or {}) do
		local lang = Leet.util.get_lang(snippet.lang_slug)
		if lang then
			items[#items + 1] = {
				label = lang.lang,
				keywords = lang.slug,
				prefix = { { lang.icon .. " ", lang.hl or ("leetcode_lang_" .. lang.slug) } },
				suffix = problem.lang == lang.slug and { { t("current"), "leetcode_muted" } } or nil,
				value = lang,
			}
		end
	end

	Markup.picker({
		title = t("Available Languages"),
		width = 50,
		height = math.min(#items, 15),
		items = items,
		on_select = function(lang)
			if problem.lang == lang.slug then
				return log.warn(("%s: %s"):format(t("Language already set to"), lang.lang))
			end

			config.lang = lang.slug
			if cb then
				cb(lang.slug)
			else
				problem:change_lang(lang.slug)
			end
		end,
	})
end

--- Switches to the tab of an open problem.
function P.tabs()
	local tabs = Leet.util.question_tabs()
	if vim.tbl_isempty(tabs) then
		return log.warn("No questions opened")
	end

	local current = vim.api.nvim_get_current_tabpage()
	local items = vim.tbl_map(function(tab)
		local problem = tab.question
		local q = problem.problem
		local lang = Leet.util.get_lang(problem.lang)

		return {
			label = Leet.util.translate(q.title, q.translated_title),
			keywords = tostring(q.frontend_id),
			prefix = {
				{ tab.tabpage == current and config.icons.caret.right or " ", "leetcode_accent" },
				{ " " .. (lang and lang.icon or " ") .. " ", lang and lang.hl or nil },
				{ q.frontend_id .. ". ", ui.diff_to_hl(q.difficulty) },
			},
			value = tab,
		}
	end, tabs)

	Markup.picker({
		title = t("Select a Question"),
		width = 80,
		height = math.min(#items, 15),
		items = items,
		on_select = function(tab)
			local ok, err = pcall(vim.api.nvim_set_current_tabpage, tab.tabpage)
			if not ok then
				log.error(err)
			end
		end,
	})
end

return P
