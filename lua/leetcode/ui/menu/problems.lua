--- The page with ways into problems, and the ones the user was just working on.

local m = require("markup")
local kit = require("leetcode.ui.kit")
local config = require("leetcode.config")
local recent = require("leetcode.ui.menu.recent")
local t = require("leetcode.translator")
local Button = require("leetcode.ui.menu.button")
local Buttons = require("leetcode.ui.menu.buttons")
local PageBar = require("leetcode.ui.menu.page_bar")

local RECENT = 5

local status_labels = { ac = "Solved", notac = "Attempted", todo = "Not solved" }

---@param item leet.ui.menu.recent.item
---@param index integer
---@param width integer room for the title
local function Recent(item, index, width)
	local problem = item.problem
	local status = config.icons.hl.status[problem.status]
	local title = Leet.util.translate(problem.title, problem.title_cn)

	return Button({
		icon = status and status[1] or config.icons.status.todo,
		icon_hl = status and status[2] or "leetcode_muted",
		title = kit.truncate(("%s. %s"):format(problem.frontend_id, title), width),
		desc = ("%s · %s · %s"):format(
			t(status_labels[problem.status] or status_labels.todo),
			t(problem.difficulty),
			recent.ago(item.time)
		),
		lhs = tostring(index),
		on_submit = function()
			require("leetcode.cmd").open(problem)
		end,
	})
end

local function Actions()
	local cmd = require("leetcode.cmd")

	return Buttons({
		Button({
			icon = "\u{f03a}",
			title = "List",
			desc = "Browse and filter",
			lhs = "p",
			on_submit = function()
				require("leetcode.ui.browser").open(require("leetcode.cache.problems").get())
			end,
		}),
		Button({
			icon = "\u{f074}",
			title = "Random",
			desc = "Pick one for me",
			lhs = "s",
			on_submit = cmd.random_question,
		}),
		Button({
			icon = kit.icons.calendar,
			title = "Daily",
			desc = "Today's challenge",
			lhs = "i",
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
		m.block({ margin_bottom = 1, padding = { 0, 1 }, m.inline(t("Recent"), "leetcode_muted") }),
		#rows > 0 and Buttons({ children = rows }) or m.block({
			padding = { 0, 1 },
			m.inline("Problems you work on will show up here", "leetcode_muted"),
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
		m.block({ margin_bottom = 1, padding = { 0, 1 }, m.inline(t("Open"), "leetcode_muted") }),
		Actions(),
	})
	local recents = RecentCard(props.columns and 46 or width)

	return m.vflex({
		align = "center",
		margin_top = 1,
		PageBar({
			title = "Problems",
			width = width,
			actions = {
				{
					title = "Back",
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
