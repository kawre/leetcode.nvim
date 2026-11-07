local m = require("markup")
local kit = require("leetcode.ui.kit")
local statistics = require("leetcode.api.stats")
local Spinner = require("leetcode.logger.spinner")
local t = require("leetcode.translator")

local BAR_WIDTH = 16

local data = m.signal(nil)

---@class leet.ui.solved
local M = {}

function M.fetch()
	statistics.solved(function(res, err)
		if err then
			return Markup.log.error(err)
		end
		data(res)
	end)
end

function M.update()
	local spinner = Spinner:start("updating solved problems")
	statistics.solved(function(res, err)
		if err then
			spinner:error(err.msg)
		else
			spinner:success("solved problems updated")
			data(res)
		end
	end)
end

--- Solved and total counts of a difficulty.
---@param difficulty string
---@return { solved: integer, total: integer }
local function stat_of(difficulty)
	local res = data()
	local stat = { solved = 0, total = 0 }

	for _, item in ipairs(res and res.submit_stats.acSubmissionNum or {}) do
		if item.difficulty == difficulty then
			stat.solved = item.count
		end
	end
	for _, item in ipairs(res and res.questions_count or {}) do
		if item.difficulty == difficulty then
			stat.total = item.count
		end
	end
	return stat
end

local function Row(difficulty, index)
	local delay = 150 + index * 120
	local stat = m.memo(function()
		return stat_of(difficulty)
	end)
	local solved = kit.counter(function()
		return stat().solved
	end, { delay = delay, instant = Leet.menu.settled() })

	return m.flex({
		justify = "between",
		white_space = "nowrap",
		m.inline({ width = 8, m.inline(t(difficulty), "leetcode_" .. difficulty:lower()) }),
		kit.Bar({
			width = BAR_WIDTH,
			delay = delay,
			instant = Leet.menu.settled(),
			style = "leetcode_bar_" .. difficulty:lower(),
			value = function()
				local current = stat()
				return current.total > 0 and current.solved / current.total or 0
			end,
		}),
		m.inline({
			margin_left = 2,
			width = 8,
			m.inline(function()
				return tostring(math.floor(solved() + 0.5))
			end, "leetcode_strong"),
			m.inline(function()
				return "/" .. stat().total
			end, "leetcode_muted"),
		}),
	})
end

M.Solved = m.component(function(props)
	if not data() then
		M.fetch()
	end

	local total = kit.counter(function()
		return stat_of("All").solved
	end, { instant = Leet.menu.settled() })

	return kit.Card({
		width = props.width,
		m.flex({
			justify = "between",
			margin_bottom = 1,
			m.inline(t("Solved"), "leetcode_muted"),
			m.inline({
				m.inline(function()
					return tostring(math.floor(total() + 0.5))
				end, "leetcode_strong"),
				m.inline(function()
					return " / " .. stat_of("All").total
				end, "leetcode_muted"),
			}),
		}),
		m.vflex({ spacing = 1, Row("Easy", 1), Row("Medium", 2), Row("Hard", 3) }),
	})
end)

return M
