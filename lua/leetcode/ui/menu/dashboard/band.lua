--- The top of the dashboard on one line: who is here, how long their streak is,
--- and how much they solved. Before signing in it says only that.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local data = require("leetcode.ui.menu.data")
local solved = require("leetcode.ui.menu.solved")

local function greeting()
	local hour = tonumber(os.date("%H"))
	return hour < 5 and "night" or hour < 12 and "morning" or hour < 18 and "afternoon" or "evening"
end

local function Count(difficulty, style, label, delay)
	local count = kit.counter(function()
		return solved.stat_of(difficulty).solved
	end, { delay = delay, instant = Leet.menu.settled() })

	return m.inline({
		m.inline(function()
			return tostring(math.floor(count() + 0.5))
		end, style),
		label and m.inline(" " .. label, "leetcode_muted"),
	})
end

---@param props { width: integer, compact?: boolean }
return m.component(function(props)
	local auth = Leet.auth()
	local separator = m.inline(" · ", "leetcode_muted")

	local brand = m.inline({
		m.inline(kit.icons.code .. " ", "leetcode_accent"),
		m.inline("leetcode.nvim", "leetcode_strong"),
		auth
			and not props.compact
			and m.inline("   " .. i18n.greeting(greeting(), auth.name), "leetcode_muted"),
	})

	local right
	if not auth then
		right = m.inline(i18n.not_signed_in, "leetcode_muted")
	else
		if not solved.data() then
			solved.fetch()
		end
		local streak = kit.counter(function()
			return data.streak().streakCount
		end, { duration = 1100, instant = Leet.menu.settled() })

		right = m.inline({
			m.inline(function()
				if not data.streak().streakCount then
					return ""
				end
				return m.inline({
					m.inline({
						style = function()
							return data.streak().todayCompleted and "leetcode_flame"
								or "leetcode_flame_off"
						end,
						kit.icons.fire .. " ",
					}),
					m.inline(function()
						return tostring(math.floor(streak() + 0.5))
					end, "leetcode_strong"),
					m.inline("   "),
				})
			end),
			Count("All", "leetcode_strong", i18n.solved_count, 100),
			not props.compact and m.inline({
				separator,
				Count("Easy", "leetcode_easy", i18n.difficulty("easy"), 200),
				separator,
				Count("Medium", "leetcode_medium", i18n.difficulty("medium"), 300),
				separator,
				Count("Hard", "leetcode_hard", i18n.difficulty("hard"), 400),
			}),
		})
	end

	return kit.Card({
		width = props.width,
		style = "leetcode_band",
		m.flex({ justify = "between", white_space = "nowrap", brand, right }),
	})
end)
