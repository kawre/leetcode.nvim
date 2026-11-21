--- A problem worth going to straight from the menu, on a card of its own.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local config = require("leetcode.config")
local ui = require("leetcode.ui.util")
local focus = require("leetcode.ui.menu.dashboard.focus")
local Frame = require("leetcode.ui.menu.dashboard.frame")

local animate = Markup.animate

---@class leet.ui.menu.problem_card
---@field label string what the problem is to the user
---@field icon string
---@field aside? string beside the key, such as a date
---@field accent? boolean warm, and the label always lit, for what stands out
---@field lhs string
---@field width integer
---@field problem? leet.cache.problem nil while it is on its way
---@field extra? string after the status and difficulty
---@field detail? string what pressing it does, for the line below the tiles
---@field on_press fun(task: leet.ui.task) given a task, see `kit.use_task`, with a loader for the icon until it is done

---@param props leet.ui.menu.problem_card
return m.component(function(props)
	local busy, start = kit.use_task()
	local function press()
		start(props.on_press)
	end
	m.use_key(props.lhs, press, { nowait = true })

	local on_focus, selected, dimmed = focus.use({
		id = "card." .. props.lhs,
		title = props.label,
		detail = props.detail,
	})
	--- A group, or the one it steps back to while something else is lit.
	local function text(group, back)
		return function()
			return dimmed() and (back or "leetcode_dim") or group
		end
	end

	local rest = props.accent and "leetcode_daily" or "leetcode_surface"
	local active = props.accent and "leetcode_daily_active" or "leetcode_row_active"
	local lift = m.animated(0, { duration = 110 })
	local tint = animate.tint(
		{ bg = kit.color(rest, "bg") },
		{ bg = kit.color(active, "bg") },
		lift
	)

	local function body()
		local problem = props.problem
		if not problem then
			return m.block({ kit.Loading(), m.block(" ") })
		end

		local status = config.icons.hl.status[problem.status]
		local number = problem.frontend_id .. ". "
		local title = Leet.util.translate(problem.title, problem.title_cn)
		local separator = m.inline(" · ", "leetcode_muted")

		return m.block({
			m.block({
				white_space = "nowrap",
				m.inline({ style = text("leetcode_muted"), number }),
				m.inline({
					style = text("leetcode_strong", "leetcode_soft"),
					kit.truncate(title, props.width - 4 - vim.api.nvim_strwidth(number)),
				}),
			}),
			m.block({
				white_space = "nowrap",
				m.inline({
					style = status and status[2] or text("leetcode_muted"),
					i18n.status(problem.status),
				}),
				separator,
				m.inline({
					style = ui.diff_to_hl(problem.difficulty),
					i18n.difficulty(problem.difficulty),
				}),
				props.extra and separator,
				props.extra and m.inline({ style = text("leetcode_muted"), props.extra }),
			}),
		})
	end

	return Frame({
		selected = selected,
		width = props.width,
		on_press = press,
		on_hover = function(hovered)
			lift(hovered and 1 or 0)
			on_focus(hovered)
		end,
		style = tint,
		children = {
			m.flex({
				justify = "between",
				margin_bottom = 1,
				m.inline({
					style = function()
						if dimmed() then
							return "leetcode_muted"
						end
						return (props.accent or lift() > 0.5) and "leetcode_accent"
							or "leetcode_muted"
					end,
					m.inline(function()
						return busy() and m.inline({ m.loader(), " " }) or props.icon .. " "
					end),
					m.inline(props.label),
				}),
				m.inline({
					props.aside
						and m.inline({ style = text("leetcode_muted"), props.aside .. " " }),
					-- The key fills in when lit; at rest the same cells keep it in place.
					m.inline({
						style = function()
							return selected() and "leetcode_tab_active"
								or text("leetcode_key", "leetcode_muted")()
						end,
						" " .. props.lhs .. " ",
					}),
				}),
			}),
			body(),
		},
	})
end)
