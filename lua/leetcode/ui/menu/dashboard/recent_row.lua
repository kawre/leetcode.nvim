--- A problem worked on lately, opened with its number: on one row, or with
--- `detailed` on two, the second saying where it stands.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local recent = require("leetcode.ui.menu.recent")
local ui = require("leetcode.ui.util")
local config = require("leetcode.config")
local focus = require("leetcode.ui.menu.dashboard.focus")

---@param p { item: leet.ui.menu.recent.item, index: integer, width: integer, detailed?: boolean }
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

	--- A group, or the one it steps back to while something else is lit.
	local function text(group, back)
		return function()
			return dimmed() and (back or "leetcode_dim") or group
		end
	end

	local number = problem.frontend_id .. ". "
	local ago = recent.ago(p.item.time)

	local function marker()
		return m.inline(function()
			return busy() and m.loader({ style = "leetcode_accent" })
				or (selected() and "▌" or " ")
		end, "leetcode_accent")
	end

	local key = m.inline({
		style = function()
			return selected() and "leetcode_tab_active" or text("leetcode_key", "leetcode_muted")()
		end,
		" " .. lhs .. " ",
	})

	local row = {
		width = p.width,
		white_space = "nowrap",
		click = "double",
		on_press = press,
		on_hover = on_hover,
		style = function()
			return selected() and "leetcode_row_active" or nil
		end,
	}

	if p.detailed then
		local status = config.icons.hl.status[problem.status]
		local language = vim.iter(config.langs):find(function(lang)
			return lang.ft == p.item.ext
		end)
		local separator = m.inline({ style = text("leetcode_muted"), " · " })
		local room = p.width - 4 - vim.api.nvim_strwidth(number) - 6

		return m.block(vim.tbl_extend("force", row, {
			m.flex({
				justify = "between",
				m.inline({
					marker(),
					m.inline({ style = text("leetcode_muted"), " " .. number }),
					m.inline({
						style = text("leetcode_strong", "leetcode_soft"),
						kit.truncate(title, room),
					}),
				}),
				key,
			}),
			m.block({
				padding = { 0, 2 },
				m.inline({
					style = status and status[2] or text("leetcode_muted"),
					i18n.status(problem.status),
				}),
				separator,
				m.inline({
					style = ui.diff_to_hl(problem.difficulty),
					i18n.difficulty(problem.difficulty),
				}),
				separator,
				m.inline({ style = text("leetcode_muted"), ago }),
				language and separator,
				language and m.inline(language.icon, language.hl or "leetcode_accent"),
			}),
		}))
	end

	-- The marker, the difficulty, the time and the key take the rest.
	local room = p.width - 4 - vim.api.nvim_strwidth(number) - 10 - vim.api.nvim_strwidth(ago) - 4

	return m.flex(vim.tbl_extend("force", row, {
		justify = "between",
		m.inline({
			marker(),
			m.inline({ style = text("leetcode_muted"), " " .. number }),
			m.inline({
				style = text("leetcode_strong", "leetcode_soft"),
				kit.truncate(title, room),
			}),
			m.inline({
				style = ui.diff_to_hl(problem.difficulty),
				"  " .. i18n.difficulty(problem.difficulty),
			}),
		}),
		m.inline({ m.inline({ style = text("leetcode_muted"), ago .. "  " }), key }),
	}))
end)
