--- The page with ways into problems, and the ones the user was just working on,
--- in the same tiles and rows as the dashboard.

local i18n = require("leetcode.i18n")
local m = require("markup")
local recent = require("leetcode.ui.menu.recent")
local Header = require("leetcode.ui.menu.dashboard.header")
local Tile = require("leetcode.ui.menu.dashboard.tile")
local RecentRow = require("leetcode.ui.menu.dashboard.recent_row")
local Echo = require("leetcode.ui.menu.dashboard.echo")

local RECENT = 5
local GAP = 2

local function tiles(width)
	local cmd = require("leetcode.cmd")
	return {
		Tile({
			id = "problems.browse",
			title = i18n.browse,
			desc = i18n.browse_tile,
			detail = i18n.browse_desc,
			lhs = "p",
			width = width,
			on_press = function()
				require("leetcode.ui.browser").open(require("leetcode.cache.problems").get())
			end,
		}),
		Tile({
			id = "problems.random",
			title = i18n.random,
			desc = i18n.random_tile,
			detail = i18n.random_detail,
			lhs = "r",
			width = width,
			async = true,
			on_press = function(task)
				cmd.random_question(nil, task)
			end,
		}),
		Tile({
			id = "problems.refresh",
			title = i18n.refresh,
			desc = i18n.refresh_tile,
			detail = i18n.refresh_desc,
			lhs = "u",
			width = width,
			on_press = function()
				require("leetcode.cmd").cache_update()
			end,
		}),
		Tile({
			id = "problems.daily",
			title = i18n.daily,
			desc = i18n.daily_tile,
			detail = i18n.daily_detail,
			lhs = "t",
			width = width,
			async = true,
			on_press = cmd.qot,
		}),
	}
end

local function Recent(width)
	local items = recent.list(RECENT)
	local rows = {}
	for i, item in ipairs(items) do
		rows[i] = RecentRow({ item = item, index = i, width = width, detailed = true })
	end

	return m.block({
		width = width,
		m.block({ padding = { 0, 1 }, margin_bottom = 1, m.inline(i18n.recent, "leetcode_muted") }),
		#rows > 0 and m.vflex({ spacing = 1, children = rows })
			or m.block({ padding = { 0, 1 }, m.inline(i18n.recent_empty, "leetcode_muted") }),
	})
end

---@param props { width: integer, columns?: boolean }
return m.component(function(props)
	-- The page moving in is the entrance, so the rows do not make one of their own.
	Leet.menu.rows = 0
	Leet.menu.rows_enter = false

	local per_row = props.columns and 4 or 2
	local tile = math.floor((props.width - GAP * (per_row - 1)) / per_row)
	local width = tile * per_row + GAP * (per_row - 1)

	local all = tiles(tile)
	local row_of_tiles = props.columns and m.flex({ spacing = GAP, children = all })
		or m.vflex({
			spacing = 1,
			m.flex({ spacing = GAP, all[1], all[2] }),
			m.flex({ spacing = GAP, all[3], all[4] }),
		})

	return m.vflex({
		align = "center",
		margin_top = 1,
		Header({
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
		row_of_tiles,
		m.block({ margin_top = 1, Echo(width) }),
		m.block({ margin_top = 1, Recent(width) }),
	})
end)
