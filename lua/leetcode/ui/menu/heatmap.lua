local m = require("markup")
local kit = require("leetcode.ui.kit")
local api = require("leetcode.api.stats")

local WEEKS = 53
local DAY = 24 * 60 * 60
local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

---@class leet.ui.heatmap.summary
---@field total integer submissions in the shown days
---@field active integer days with a submission
---@field best integer longest run of active days
---@field days table[] `{ level, month }` by week and weekday
---@field labels string month names placed above their first week

--- Turns the submission calendar into a grid of weeks, ending today.
---@param calendar table<string, integer> counts by the timestamp of their day
---@param now integer
---@return leet.ui.heatmap.summary
local function summarize(calendar, now)
	local counts, max = {}, 0
	for timestamp, count in pairs(calendar) do
		local day = os.date("!%Y-%m-%d", tonumber(timestamp))
		counts[day] = (counts[day] or 0) + count
		max = math.max(max, counts[day])
	end

	local weekday = tonumber(os.date("!%w", now))
	local first = now - (weekday + (WEEKS - 1) * 7) * DAY

	local summary = { total = 0, active = 0, best = 0, weeks = {} }
	local labels = {}
	local run, last_month = 0, nil

	for week = 1, WEEKS do
		summary.weeks[week] = {}
		for day = 1, 7 do
			local time = first + ((week - 1) * 7 + day - 1) * DAY
			if time <= now then
				local count = counts[os.date("!%Y-%m-%d", time)] or 0
				summary.total = summary.total + count
				summary.active = summary.active + (count > 0 and 1 or 0)
				run = count > 0 and run + 1 or 0
				summary.best = math.max(summary.best, run)
				summary.weeks[week][day] = count > 0 and math.ceil(count / max * 4) or 0

				local month = tonumber(os.date("!%m", time))
				if day == 1 and month ~= last_month then
					last_month = month
					labels[week] = MONTHS[month]
				end
			else
				summary.weeks[week][day] = -1
			end
		end
	end

	local text, week = {}, 1
	while week <= WEEKS do
		local label = labels[week]
		if label and week + #label <= WEEKS then
			text[#text + 1] = label
			week = week + #label
		else
			text[#text + 1] = " "
			week = week + 1
		end
	end
	summary.labels = table.concat(text)

	return summary
end

--- Rows of half blocks: two days fit in each cell, and the cells are square.
local function Grid(summary)
	local reveal = m.animated(0, { duration = 900, delay = 100, easing = "out_cubic" })
	reveal(WEEKS)

	local visible = {}
	for week = 1, WEEKS do
		visible[week] = m.memo(function()
			return reveal() >= week - 0.5
		end)
	end

	local rows = {}
	for row = 1, 4 do
		local cells = {}
		for week = 1, WEEKS do
			local top = summary.weeks[week][row * 2 - 1]
			local bottom = summary.weeks[week][row * 2] or -1
			local group = ("leetcode_heat_%d_%d"):format(top + 1, bottom + 1)
			local hidden = ("leetcode_heat_%d_%d"):format(top < 0 and 0 or 1, bottom < 0 and 0 or 1)

			cells[week] = m.inline({
				style = function()
					return visible[week]() and group or hidden
				end,
				"▀",
			})
		end
		rows[row] = m.block({ white_space = "nowrap", cells })
	end

	return m.block({ width = WEEKS, rows })
end

local function Stat(value, label)
	local shown = kit.counter(function()
		return value
	end, { delay = 200 })

	return m.block({
		m.inline(function()
			return tostring(math.floor(shown() + 0.5))
		end, "leetcode_strong"),
		m.inline(" " .. label, "leetcode_muted"),
	})
end

local Content = m.component(function(props)
	local summary = props.summary

	return m.flex({
		justify = "between",
		m.block({
			m.block(summary.labels, "leetcode_muted"),
			Grid(summary),
		}),
		m.block({
			width = 18,
			margin_top = 1,
			Stat(summary.total, "submissions"),
			Stat(summary.active, "active days"),
			Stat(summary.best, "best streak"),
		}),
	})
end)

return m.component(function(props)
	local summary = m.signal(nil)

	m.effect(function()
		Leet.menu.stats_version()

		if not Leet.auth() then
			return
		end

		api.calendar(function(data, err)
			if err then
				return Markup.log.error(err)
			end
			summary(summarize(data.calendar.submission_calendar, os.time()))
		end)
	end)

	return kit.Card({
		width = props.width,
		function()
			local current = summary()
			return current and Content({ summary = current }) or m.block("Loading...", "leetcode_muted")
		end,
	})
end)
