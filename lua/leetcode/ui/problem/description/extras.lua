--- What follows the problem itself: hints, topics and similar problems. All of it
--- starts closed, since all of it can give the solution away.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local config = require("leetcode.config")
local html = require("leetcode.ui.problem.description.html")
local ui = require("leetcode.ui.util")

---@class leet.ui.description.extras
local M = {}

--- A hint of its own, so reading one does not show the next.
local function Hint(index, total, hint)
	local open = m.signal(false)

	return m.block({
		m.block({
			width = "fit",
			click = "double",
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

--- The key that presses things, as it reads on screen.
---@return string
local function confirm_key()
	local lhs = vim.iter({ config.user.keys.confirm }):flatten():next()
	return lhs == "<CR>" and "⏎" or lhs
end

--- A similar problem, which says how to open it when the cursor is on it.
local function SimilarRow(props)
	local hovered = m.signal(false)
	-- While it is fetched. Closing the question meanwhile opens nothing.
	local busy, start = kit.use_task()

	return m.flex({
		click = "double",
		on_press = function()
			start(function(task)
				Leet.cmd.open(props.problem, task)
			end)
		end,
		on_hover = hovered,
		style = function()
			return hovered() and "leetcode_row_active" or nil
		end,
		justify = "between",
		white_space = "nowrap",
		m.inline({ shrink = 1, props.children }),
		function()
			if busy() then
				return m.inline({
					shrink = 0,
					margin_left = 2,
					margin_right = 1,
					kit.Loader("leetcode_accent"),
				})
			end
			if not hovered() then
				return nil
			end
			return m.inline({
				shrink = 0,
				margin_left = 2,
				margin_right = 1,
				m.inline(confirm_key(), "leetcode_key"),
				m.inline(" " .. i18n.open:lower(), "leetcode_muted"),
			})
		end,
	})
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
					or ((" %s "):format(config.icons.lock) .. i18n.premium)
			end

			rows[#rows + 1] = SimilarRow({
				problem = p,
				children = {
					m.inline(config.icons.square .. " ", ui.diff_to_hl(p.difficulty)),
					m.inline(p.frontend_id .. ". ", "leetcode_normal"),
					m.inline(Leet.util.translate(p.title, p.title_cn)),
					premium and m.inline(premium, "leetcode_medium"),
				},
			})
		end
	end

	return rows
end

--- In the order they appear.
M.sections = {
	{ name = "hints", title = "hints", hl = "leetcode_hint", rows = hints },
	{ name = "topics", title = "topics", hl = "Number", rows = topics },
	{ name = "similar", title = "similar_questions", hl = "leetcode_ref", rows = similar },
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
			local title = i18n[section.title]

			sections[section.name] = { open = open, title = title }
			elements[#elements + 1] =
				html.Section({ title = title, hl = section.hl, body = rows, open = open })
		end
	end

	return elements, sections
end

return M
