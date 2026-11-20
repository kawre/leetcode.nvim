--- The page with ways into problems, and the ones the user was just working on.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local config = require("leetcode.config")
local recent = require("leetcode.ui.menu.recent")
local ui = require("leetcode.ui.util")
local Button = require("leetcode.ui.menu.button")
local Buttons = require("leetcode.ui.menu.buttons")
local PageBar = require("leetcode.ui.menu.page_bar")

local RECENT = 5

--- The language a solution is in, from the extension of its file.
---@param ext string
---@return lc.language?
local function language_of(ext)
	return vim.iter(config.langs):find(function(lang)
		return lang.ft == ext
	end)
end

---@param item leet.ui.menu.recent.item
---@param index integer
---@param width integer room for the number and the title
local function Recent(item, index, width)
	local problem = item.problem
	local status = config.icons.hl.status[problem.status]
	local status_hl = status and status[2] or "leetcode_muted"
	local number = problem.frontend_id .. "."
	local title = Leet.util.translate(problem.title, problem.title_cn)
	local language = language_of(item.ext)

	local separator = { " · ", "leetcode_muted" }
	local desc = {
		{ i18n.status(problem.status), status_hl },
		separator,
		{ i18n.difficulty(problem.difficulty), ui.diff_to_hl(problem.difficulty) },
		separator,
		{ recent.ago(item.time), "leetcode_muted" },
	}

	if language then
		desc[#desc + 1] = separator
		desc[#desc + 1] = { language.icon, language.hl or "leetcode_accent" }
	end

	return Button({
		icon = status and status[1] or config.icons.status.todo,
		icon_hl = status_hl,
		prefix = number,
		title = kit.truncate(title, width - vim.api.nvim_strwidth(number) - 1),
		desc = desc,
		lhs = tostring(index),
		async = true,
		on_submit = function(task)
			require("leetcode.cmd").open(problem, task)
		end,
	})
end

local function Actions()
	local cmd = require("leetcode.cmd")

	return Buttons({
		Button({
			icon = "\u{f03a}",
			title = i18n.browse,
			desc = i18n.browse_desc,
			lhs = "p",
			on_submit = function()
				require("leetcode.ui.browser").open(require("leetcode.cache.problems").get())
			end,
		}),
		Button({
			icon = "\u{f074}",
			title = i18n.random,
			desc = i18n.random_desc,
			lhs = "s",
			async = true,
			on_submit = function(task)
				cmd.random_question(nil, task)
			end,
		}),
		Button({
			icon = "\u{f0450}",
			title = i18n.refresh,
			desc = i18n.refresh_desc,
			lhs = "r",
			on_submit = function()
				require("leetcode.cmd").cache_update()
			end,
		}),
		Button({
			icon = kit.icons.calendar,
			title = i18n.daily_challenge,
			desc = i18n.todays_problem,
			lhs = "i",
			async = true,
			on_submit = cmd.qot,
		}),
	})
end

local function RecentCard(width)
	local items = recent.list(RECENT)
	local rows = {}
	-- The card, the marker and the icon come first, and the key ends the row.
	local room = width - 12

	for i, item in ipairs(items) do
		rows[i] = Recent(item, i, room)
	end

	return kit.Card({
		width = width,
		padding = { 0, 1 },
		m.block({ margin_bottom = 1, padding = { 0, 1 }, m.inline(i18n.recent, "leetcode_muted") }),
		#rows > 0 and Buttons({ children = rows }) or m.block({
			padding = { 0, 1 },
			m.inline(i18n.recent_empty, "leetcode_muted"),
		}),
	})
end

--- `props.width` is the room for all of it, and `props.columns` says if the two
--- groups fit side by side.
return m.component(function(props)
	local width = props.width

	-- The page moving in is the entrance, so the rows do not make one of their own.
	Leet.menu.rows = 0
	Leet.menu.rows_enter = false

	local actions = kit.Card({
		width = props.columns and 30 or width,
		padding = { 0, 1 },
		m.block({ margin_bottom = 1, padding = { 0, 1 }, m.inline(i18n.open, "leetcode_muted") }),
		Actions(),
	})
	local recents = RecentCard(props.columns and 46 or width)

	return m.vflex({
		align = "center",
		margin_top = 1,
		PageBar({
			title = i18n.problems,
			width = width,
			actions = {
				{
					title = i18n.back,
					lhs = "q",
					press = function()
						Leet.menu.set_page("menu")
					end,
				},
			},
		}),
		props.columns and m.flex({ width = width, justify = "between", actions, recents })
			or m.block({ width = width, recents, actions }),
	})
end)
