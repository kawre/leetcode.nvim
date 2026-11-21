--- The top of the menu, the whole width of the window, on one line: who is here, how long their streak is,
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

--- Cells at either end of the band.
local PADDING = 3

local function Brand(greeting_text, room)
	return m.inline({
		m.inline(kit.icons.code .. " ", "leetcode_accent"),
		m.inline("leetcode.nvim", "leetcode_strong"),
		-- The greeting goes first when the band runs out of room.
		greeting_text and m.inline(function()
			return vim.api.nvim_strwidth(greeting_text) <= room() and greeting_text or ""
		end, "leetcode_muted"),
	})
end

--- The band of a signed in user: who it is, the streak and what was solved.
---@param props { width: integer, compact?: boolean, name: string }
local SignedIn = m.component(function(props)
	if not solved.data() then
		solved.fetch()
	end

	local separator = m.inline(" · ", "leetcode_muted")
	local hello = "   " .. i18n.greeting(greeting(), props.name)

	--- How wide the right side is, as plain text.
	local function right_width()
		local text = ("%s   %d %s"):format(
			tostring(data.streak().streakCount or ""),
			solved.stat_of("All").solved,
			i18n.solved_count
		)
		if not props.compact then
			for _, difficulty in ipairs({ "Easy", "Medium", "Hard" }) do
				local count = solved.stat_of(difficulty).solved
				text = text .. (" · %d %s"):format(count, i18n.difficulty(difficulty:lower()))
			end
		end
		return vim.api.nvim_strwidth(text) + 2
	end

	local streak = kit.counter(function()
		return data.streak().streakCount
	end, { duration = 1100, instant = Leet.menu.settled() })

	local right = m.inline({
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

	local brand = Brand(hello, function()
		return props.width - PADDING * 2 - 15 - right_width() - 2
	end)
	return m.flex({ justify = "between", white_space = "nowrap", brand, right })
end)

---@param props { width: integer, compact?: boolean }
return m.component(function(props)
	return kit.Card({
		width = props.width,
		style = "leetcode_band",
		padding = { 0, PADDING },
		-- Signing in ends after the band shows, so it follows who is here.
		function()
			local auth = Leet.auth()
			if not auth then
				return m.flex({
					justify = "between",
					white_space = "nowrap",
					Brand(),
					m.inline(i18n.not_signed_in, "leetcode_muted"),
				})
			end
			return SignedIn({ width = props.width, compact = props.compact, name = auth.name })
		end,
	})
end)
