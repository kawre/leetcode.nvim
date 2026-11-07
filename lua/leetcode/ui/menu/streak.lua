local m = require("markup")
local kit = require("leetcode.ui.kit")
local api = require("leetcode.api.stats")

return m.component(function(props)
	local streak = m.signal({})

	m.effect(function()
		Leet.menu.stats_version()

		if not Leet.auth() then
			return
		end

		api.streak(function(data, err)
			if err then
				return Markup.log.error(err)
			end
			streak(data)
		end)
	end)

	local count = kit.counter(function()
		return streak().streakCount
	end, { duration = 1100 })

	return kit.Card({
		width = props.width,
		m.flex({
			spacing = 2,
			kit.BigNumber({ value = count, style = "leetcode_accent" }),
			m.block({
				m.block({
					m.inline({
						style = function()
							return streak().todayCompleted and "leetcode_flame" or "leetcode_flame_off"
						end,
						kit.icons.fire .. " ",
					}),
					m.inline("day streak", "leetcode_strong"),
				}),
				m.block(function()
					return streak().todayCompleted and "done for today" or "keep it alive"
				end, "leetcode_muted"),
			}),
		}),
	})
end)
