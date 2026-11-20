--- Solved problems on one line, below the launcher.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local solved = require("leetcode.ui.menu.solved")

local function Count(difficulty, style, label, delay)
	local count = kit.counter(function()
		return solved.stat_of(difficulty).solved
	end, { delay = delay, instant = Leet.menu.settled() })

	return m.inline({
		m.inline(function()
			return tostring(math.floor(count() + 0.5))
		end, style),
		m.inline(" " .. label, "leetcode_muted"),
	})
end

return m.component(function()
	if not solved.data() then
		solved.fetch()
	end

	local separator = m.inline(" · ", "leetcode_muted")

	return m.block({
		white_space = "nowrap",
		Count("All", "leetcode_strong", i18n.solved_count, 100),
		separator,
		Count("Easy", "leetcode_easy", i18n.difficulty("easy"), 200),
		separator,
		Count("Medium", "leetcode_medium", i18n.difficulty("medium"), 300),
		separator,
		Count("Hard", "leetcode_hard", i18n.difficulty("hard"), 400),
	})
end)
