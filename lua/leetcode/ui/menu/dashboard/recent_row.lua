--- A problem worked on lately, on one row, opened with its number.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local recent = require("leetcode.ui.menu.recent")
local ui = require("leetcode.ui.util")
local focus = require("leetcode.ui.menu.dashboard.focus")

---@param p { item: leet.ui.menu.recent.item, index: integer, width: integer }
return m.component(function(p)
	local problem = p.item.problem
	local title = Leet.util.translate(problem.title, problem.title_cn)
	local busy, start = kit.use_task()
	local on_hover, selected, dimmed = focus.use({
		id = "recent." .. p.index,
		title = title,
		detail = i18n.open_recent_detail,
	})

	local function press()
		start(function(task)
			require("leetcode.cmd").open(problem, task)
		end)
	end
	local lhs = tostring(p.index)
	m.use_key(lhs, press, { nowait = true })

	local function text(group)
		return function()
			return dimmed() and "leetcode_dim" or group
		end
	end

	local number = problem.frontend_id .. ". "
	local ago = recent.ago(p.item.time)
	-- The marker, the difficulty, the time and the key take the rest.
	local room = p.width - 4 - vim.api.nvim_strwidth(number) - 10 - vim.api.nvim_strwidth(ago) - 4

	return m.flex({
		width = p.width,
		justify = "between",
		white_space = "nowrap",
		click = "double",
		on_press = press,
		on_hover = on_hover,
		style = function()
			return selected() and "leetcode_row_active" or nil
		end,
		m.inline({
			m.inline(function()
				return busy() and m.loader({ style = "leetcode_accent" })
					or (selected() and "▌" or " ")
			end, "leetcode_accent"),
			m.inline({ style = text("leetcode_muted"), " " .. number }),
			m.inline({ style = text("leetcode_strong"), kit.truncate(title, room) }),
			m.inline({
				style = text(ui.diff_to_hl(problem.difficulty)),
				"  " .. i18n.difficulty(problem.difficulty),
			}),
		}),
		m.inline({
			m.inline({ style = text("leetcode_muted"), ago .. "  " }),
			m.inline({
				style = function()
					return selected() and "leetcode_tab_active" or text("leetcode_key")()
				end,
				" " .. lhs .. " ",
			}),
		}),
	})
end)
