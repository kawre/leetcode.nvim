--- A way into the plugin, on a tile of its own: its key, its name and a word on
--- what it holds. The one under the cursor lights up, and the rest step back.

local m = require("markup")
local kit = require("leetcode.ui.kit")
local focus = require("leetcode.ui.menu.dashboard.focus")
local Frame = require("leetcode.ui.menu.dashboard.frame")

---@class leet.ui.menu.tile
---@field id string
---@field title string
---@field desc string
---@field detail string what pressing it does
---@field lhs string
---@field width integer
---@field page? string the page it opens
---@field on_press? fun(task?: leet.ui.task)
---@field async? boolean `on_press` gets a task, and a loader shows until it is done

---@param p leet.ui.menu.tile
return m.component(function(p)
	local busy, start = kit.use_task()
	local on_hover, selected, dimmed = focus.use({ id = p.id, title = p.title, detail = p.detail })

	local function press()
		if p.async then
			start(p.on_press)
		elseif p.page then
			Leet.menu.set_page(p.page)
		elseif p.on_press then
			p.on_press()
		end
	end
	m.use_key(p.lhs, press, { noremap = false, silent = true, nowait = true })

	return Frame({
		selected = selected,
		width = p.width,
		on_press = press,
		on_hover = on_hover,
		style = function()
			return selected() and "leetcode_row_active" or "leetcode_surface"
		end,
		children = {
			m.block({
				white_space = "nowrap",
				-- The key fills in when lit; at rest the same cells keep it in place.
				m.inline({
					style = function()
						return selected() and "leetcode_tab_active"
							or dimmed() and "leetcode_muted"
							or "leetcode_key"
					end,
					" " .. p.lhs .. " ",
				}),
				m.inline({
					style = function()
						return dimmed() and "leetcode_soft" or "leetcode_strong"
					end,
					" " .. p.title,
				}),
				m.inline(function()
					return busy() and m.inline({ " ", m.loader({ style = "leetcode_accent" }) })
						or ""
				end),
			}),
			m.block({
				white_space = "nowrap",
				m.inline({
					style = function()
						return dimmed() and "leetcode_dim" or "leetcode_muted"
					end,
					kit.truncate(p.desc, p.width - 4),
				}),
			}),
		},
	})
end)
