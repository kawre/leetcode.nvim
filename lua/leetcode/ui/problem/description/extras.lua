--- What follows the problem itself: hints, topics and similar problems. All of it
--- starts closed, since all of it can give the solution away.

local m = require("markup")
local config = require("leetcode.config")
local html = require("leetcode.ui.problem.description.html")
local t = require("leetcode.translator")
local ui = require("leetcode.ui.util")

---@class leet.ui.description.extras
local M = {}

--- A hint of its own, so reading one does not show the next.
local function Hint(index, total, hint)
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
			m.inline(("%d/%d"):format(index, total), "leetcode_list"),
		}),
		m.collapse(open, function()
			return m.block({ margin_bottom = index < total and 1 or 0, html.parse(hint) })
		end),
	})
end

local function hints(problem)
	local list = problem.hints or {}
	local rows = {}
	for i, hint in ipairs(list) do
		rows[i] = Hint(i, #list, hint)
	end
	return rows
end

local function topics(problem)
	return vim.tbl_map(function(topic)
		return m.block({ m.inline("* ", "leetcode_list"), m.inline(topic.name) })
	end, problem.topic_tags or {})
end

local function similar(problem)
	local cache = require("leetcode.cache.problems")
	local rows = {}

	for _, q in ipairs(problem.similar or {}) do
		local ok, p = pcall(cache.by_slug, q.title_slug)
		if ok then
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
				m.inline(p.frontend_id .. ". ", "leetcode_normal"),
				m.inline(Leet.util.translate(p.title, p.title_cn)),
				premium and m.inline(premium, "leetcode_medium"),
			})
		end
	end

	return rows
end

--- In the order they appear.
M.sections = {
	{ name = "hints", title = "Hints", hl = "leetcode_hint", rows = hints },
	{ name = "topics", title = "Topics", hl = "Number", rows = topics },
	{ name = "similar", title = "Similar Questions", hl = "leetcode_ref", rows = similar },
}

--- Builds the sections that have something to show.
---@param problem table
---@return table[] elements
---@return table<string, { open: function, title: string }> sections by name
function M.build(problem)
	local elements, sections = {}, {}

	for _, section in ipairs(M.sections) do
		local rows = section.rows(problem)
		if #rows > 0 then
			local open = m.signal(false)
			local title = t(section.title)

			sections[section.name] = { open = open, title = title }
			elements[#elements + 1] = html.Section({ title = title, hl = section.hl, body = rows, open = open })
		end
	end

	return elements, sections
end

return M
