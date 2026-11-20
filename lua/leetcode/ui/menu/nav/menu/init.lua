--- The dashboard: the problems worth going to straight away, the ways into the
--- plugin as tiles, and what was worked on lately. Wide, the cards and the
--- tiles stand side by side; narrow, they stack.

local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")
local ProblemCard = require("leetcode.ui.menu.problem_card")
local Tile = require("leetcode.ui.menu.dashboard.tile")
local RecentRow = require("leetcode.ui.menu.dashboard.recent_row")
local focus = require("leetcode.ui.menu.dashboard.focus")
local data = require("leetcode.ui.menu.data")
local recent = require("leetcode.ui.menu.recent")

--- From this wide the two cards stand side by side.
local CARDS_SIDE_BY_SIDE = 70

--- The problem worked on last, if any.
local function Continue(width)
	local item = recent.list(1)[1]
	if not item then
		return
	end

	return ProblemCard({
		label = i18n.continue,
		icon = kit.icons.resume,
		lhs = "c",
		width = width,
		problem = item.problem,
		extra = recent.ago(item.time),
		detail = i18n.continue_detail,
		click = "double",
		on_press = function(task)
			require("leetcode.cmd").open(item.problem, task)
		end,
	})
end

--- The daily challenge, which arrives a moment after the menu.
local function Today(width)
	return function()
		local problem = data.daily()

		return ProblemCard({
			label = i18n.daily_challenge,
			icon = kit.icons.calendar,
			aside = os.date(i18n.date_format),
			accent = true,
			lhs = "t",
			width = width,
			problem = problem,
			extra = problem and problem.ac_rate and i18n.accepted_rate(problem.ac_rate),
			detail = i18n.daily_detail,
			click = "double",
			on_press = function(task)
				require("leetcode.cmd").qot(task)
			end,
		})
	end
end

local function tiles(width)
	return {
		Tile({
			id = "problems",
			title = i18n.problems,
			desc = i18n.problems_tile,
			detail = i18n.problems_detail,
			lhs = "p",
			width = width,
			page = "menu.problems",
		}),
		Tile({
			id = "random",
			title = i18n.random,
			desc = i18n.random_tile,
			detail = i18n.random_detail,
			lhs = "r",
			width = width,
			async = true,
			on_press = function(task)
				require("leetcode.cmd").random_question(nil, task)
			end,
		}),
		Tile({
			id = "statistics",
			title = i18n.statistics,
			desc = i18n.statistics_tile,
			detail = i18n.statistics_detail,
			lhs = "s",
			width = width,
			page = "menu.statistics",
		}),
		Tile({
			id = "account",
			title = i18n.account,
			desc = i18n.account_tile,
			detail = i18n.account_detail,
			lhs = "a",
			width = width,
			page = "menu.cookie",
		}),
	}
end

--- What the lit tile or card does, below the tiles.
local function Echo(width)
	return m.block(function()
		local current = focus.current()
		if not current or not current.detail then
			return m.block(" ")
		end
		return m.flex({
			width = width,
			padding = { 0, 1 },
			justify = "between",
			white_space = "nowrap",
			m.inline({
				m.inline("▸ ", "leetcode_accent"),
				m.inline(kit.truncate(current.title, 24), "leetcode_strong"),
				m.inline("  " .. current.detail, "leetcode_muted"),
			}),
			m.inline({ kit.Key("<CR>"), m.inline(" " .. i18n.open_hint, "leetcode_muted") }),
		})
	end)
end

local function Recent(width, count)
	local items = recent.list(count)
	local rows = {}
	for i, item in ipairs(items) do
		rows[i] = RecentRow({ item = item, index = i, width = width })
	end

	return m.block({
		width = width,
		m.flex({
			padding = { 0, 1 },
			margin_bottom = 1,
			justify = "between",
			white_space = "nowrap",
			m.inline({
				style = function()
					return focus.any() and "leetcode_dim" or "leetcode_muted"
				end,
				i18n.recent,
			}),
			m.inline({ kit.Key("q"), m.inline(" " .. i18n.quit_hint, "leetcode_muted") }),
		}),
		#rows > 0 and m.vflex({ children = rows })
			or m.block({ padding = { 0, 1 }, m.inline(i18n.recent_empty, "leetcode_muted") }),
	})
end

---@param props { width: integer, columns?: boolean }
return m.component(function(props)
	local width = props.width
	m.use_key("q", function()
		require("leetcode").stop()
	end, { nowait = true })

	-- Two cards fit side by side long after four tiles stop fitting in a row.
	local cards
	if width >= CARDS_SIDE_BY_SIDE then
		local half = math.floor(width / 2) - 2
		local continue = Continue(half)
		cards = m.flex({
			width = width,
			justify = "between",
			continue,
			Today(continue and half or width - 2),
		})
	else
		cards = m.vflex({ Continue(width - 2), Today(width - 2) })
	end

	local row_of_tiles
	if props.columns then
		row_of_tiles = m.flex({
			width = width,
			justify = "between",
			children = tiles(math.floor(width / 4) - 2),
		})
	else
		local all = tiles(math.floor(width / 2) - 2)
		row_of_tiles = m.vflex({
			m.flex({ width = width, justify = "between", all[1], all[2] }),
			m.flex({ width = width, justify = "between", all[3], all[4] }),
		})
	end

	return m.vflex({
		align = "center",
		cards,
		row_of_tiles,
		Echo(width),
		m.block({ margin_top = 1, Recent(width, props.columns and 3 or 2) }),
	})
end)
