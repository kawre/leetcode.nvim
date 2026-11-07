local m = require("markup")
local kit = require("leetcode.ui.kit")
local data = require("leetcode.ui.menu.data")

local animate = Markup.animate

return m.component(function(props)
	local function open()
		require("leetcode.cmd").qot()
	end

	m.use_key("t", open, { nowait = true })

	local focus = m.animated(0, { duration = 110 })

	return kit.Card({
		width = props.width,
		on_press = open,
		on_hover = function(hovered)
			focus(hovered and 1 or 0)
		end,
		style = animate.tint(
			{ bg = kit.color("leetcode_surface", "bg") },
			{ bg = kit.color("leetcode_row_active", "bg") },
			focus
		),
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
