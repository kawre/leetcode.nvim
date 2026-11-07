local m = require("markup")
local kit = require("leetcode.ui.kit")
local data = require("leetcode.ui.menu.data")

return m.component(function(props)
	local function open()
		require("leetcode.cmd").qot()
	end

	m.use_key("t", open, { nowait = true })

	return kit.Card({
		width = props.width,
		on_press = open,
		m.flex({
			justify = "between",
			m.inline({
				m.inline(kit.icons.calendar .. " ", "leetcode_accent"),
				m.inline("Daily challenge", "leetcode_muted"),
			}),
			kit.Key("t"),
		}),
		function()
			local problem = data.daily()
			if not problem then
				return m.block("Loading...", "leetcode_muted")
			end

			local status = require("leetcode.config").icons.hl.status[problem.status]

			return m.block({
				m.block({
					white_space = "nowrap",
					m.inline(problem.frontend_id .. ". ", "leetcode_muted"),
					m.inline(Leet.util.translate(problem.title, problem.title_cn), "leetcode_strong"),
				}),
				m.block({
					kit.Pill(problem.difficulty, problem.difficulty),
					status and m.inline(" " .. status[1], status[2]),
				}),
			})
		end,
	})
end)
