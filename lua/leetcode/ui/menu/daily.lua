local m = require("markup")
local kit = require("leetcode.ui.kit")

return m.component(function(props)
	local daily = m.signal(nil)

	m.effect(function()
		Leet.menu.stats_version()

		if not Leet.auth() then
			return
		end

		require("leetcode.api.problems").question_of_today(function(res, err)
			if err then
				return Markup.log.error(err)
			end

			local ok, problem = pcall(function()
				return require("leetcode.cache.problems").by_slug(res.title_slug)
			end)
			daily(ok and problem or nil)
		end)
	end)

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
			local problem = daily()
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
