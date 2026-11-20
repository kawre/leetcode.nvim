local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")
local statistics = require("leetcode.api.stats")

local BAR_WIDTH = 16

local data = m.signal(nil)

---@class leet.ui.solved
local M = {}

--- What the solved stats came back as, once they did.
M.data = data

---@param done? function called once it came back, errors included
function M.fetch(done)
	statistics.solved(function(res, err)
		if done then
			done()
		end
		if err then
			return Markup.log.error(err)
		end
		data(res)
	end)
end

--- Solved and total counts of a difficulty.
---@param difficulty string
---@return { solved: integer, total: integer }
function M.stat_of(difficulty)
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

local function Row(difficulty, index, bar_width)
	local delay = 150 + index * 120
	local stat = m.memo(function()
		return M.stat_of(difficulty)
	end)
	local solved = kit.counter(function()
		return stat().solved
	end, { delay = delay, instant = Leet.menu.settled() })

	return m.flex({
		justify = "between",
		white_space = "nowrap",
		m.inline({
			width = 8,
			m.inline(i18n.difficulty(difficulty), "leetcode_" .. difficulty:lower()),
		}),
		kit.Bar({
			width = bar_width,
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
	-- The card, the label and the count take the rest.
	local bar_width = math.max((props.width or 0) - 4 - 8 - 10, BAR_WIDTH)
	if not data() then
		M.fetch()
	end

	local total = kit.counter(function()
		return M.stat_of("All").solved
	end, { instant = Leet.menu.settled() })

	return kit.HoverCard({
		width = props.width,
		grow = props.grow,
		m.flex({
			justify = "between",
			margin_bottom = 1,
			m.inline(i18n.status("ac"), "leetcode_muted"),
			m.inline({
				m.inline(function()
					return tostring(math.floor(total() + 0.5))
				end, "leetcode_strong"),
				m.inline(function()
					return " / " .. M.stat_of("All").total
				end, "leetcode_muted"),
			}),
		}),
		m.vflex({
			spacing = 1,
			Row("Easy", 1, bar_width),
			Row("Medium", 2, bar_width),
			Row("Hard", 3, bar_width),
		}),
	})
end)

return M
