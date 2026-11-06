local m = require("markup")
local Popup = require("leetcode.ui.popup")
local config = require("leetcode.config")
local html = require("leetcode.ui.problem.description.html")
local t = require("leetcode.translator")
local ui = require("leetcode.ui.util")

local function Section(title, hl, children)
	local open = m.signal(false)

	return m.block({
		m.block({
			width = "fit",
			on_press = function()
				open(not open())
			end,
			m.inline(function()
				return ui.chevron(open())
			end, "leetcode_alt"),
			m.inline(title, hl),
		}),
		m.show(open, function()
			return m.block({ padding_left = 2, children })
		end),
	})
end

local function Empty(text)
	return m.block(" " .. text, "leetcode_error")
end

local function Hints(hints)
	if vim.tbl_isempty(hints) then
		return Empty(t("No hints available"))
	end

	local rows = {}
	for i, hint in ipairs(hints) do
		rows[i] = Section(("%d/%d"):format(i, #hints), "leetcode_list", html.parse(hint))
	end
	return Section(t("Hints"), "leetcode_hint", rows)
end

local function Topics(topics)
	if vim.tbl_isempty(topics) then
		return Empty(t("No topics available"))
	end

	return Section(
		t("Topics"),
		"Number",
		vim.tbl_map(function(topic)
			return m.block({ m.inline("* ", "leetcode_list"), m.inline(topic.name) })
		end, topics)
	)
end

local function Similar(similar)
	local problems = require("leetcode.cache.problems")
	local rows = {}

	for _, q in ipairs(similar) do
		local ok, p = pcall(problems.by_slug, q.title_slug)
		if ok then
			local id = p.frontend_id .. "."
			id = id .. (" "):rep(5 - vim.api.nvim_strwidth(id))

			local premium
			if q.paid_only then
				premium = config.auth.is_premium and (" " .. config.icons.unlock)
					or ((" %s "):format(config.icons.lock) .. t("Premium"))
			end

			rows[#rows + 1] = m.block({
				width = "fit",
				on_press = function()
					Leet.cmd.open(p)
				end,
				m.inline(config.icons.square .. " ", ui.diff_to_hl(p.difficulty)),
				m.inline(id .. " ", "leetcode_normal"),
				m.inline(Leet.util.translate(p.title, p.title_cn)),
				premium and m.inline(premium, "leetcode_medium"),
			})
		end
	end

	if vim.tbl_isempty(rows) then
		return Empty(t("No similar questions available"))
	end
	return Section(t("Similar Questions"), "leetcode_ref", rows)
end

---@param problem leet.problem
return function(problem)
	return Popup({
		title = t("Question Info"),
		width = 0.5,
		height = 0.5,
		content = function()
			local q = problem.problem
			return m.block({
				padding = { 1, 2 },
				spacing = 1,
				Hints(q.hints or {}),
				Topics(q.topic_tags or {}),
				Similar(q.similar or {}),
			})
		end,
	})
end
