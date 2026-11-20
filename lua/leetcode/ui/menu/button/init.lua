local m = require("markup")
local kit = require("leetcode.ui.kit")

local animate = Markup.animate

---@class MenuButtonProps
---@field title string
---@field prefix? string muted, before the title
---@field desc? string|{ [1]: string, [2]?: string }[] text, or spans of text and highlight
---@field icon_hl? string
---@field icon string
---@field lhs string
---@field page string
---@field nested boolean
---@field on_submit function
---@field async? boolean `on_submit` gets a task, see `kit.use_task`, and the icon is a loader until it is done

---@param p MenuButtonProps
return m.component(function(p)
	local busy, start = kit.use_task()

	local function press()
		if p.on_submit and p.async then
			start(p.on_submit)
		elseif p.on_submit then
			p.on_submit()
		elseif p.page then
			Leet.menu.set_page(p.page)
		end
	end

	m.use_key(p.lhs, press, { noremap = false, silent = true, nowait = true })

	-- Rows of a page arrive one after another.
	Leet.menu.rows = Leet.menu.rows + 1
	local delay = Leet.menu.rows * 35
	local surface = kit.color("leetcode_surface", "bg")

	local enter = Leet.menu.rows_enter

	local function fade(group)
		return enter and animate.fade_in(group, surface, { delay = delay, duration = 200 }) or group
	end

	local slide = m.animated(enter and 2 or 0, { delay = delay, duration = 200 })
	slide(0)

	local focus = m.animated(0, { duration = 110 })
	local row = animate.tint(
		{ bg = surface },
		{ bg = kit.color("leetcode_row_active", "bg") },
		focus
	)

	local function description()
		if type(p.desc) == "string" then
			return m.inline(p.desc, fade("leetcode_muted"))
		end

		return vim.tbl_map(function(span)
			return m.inline(span[1], fade(span[2] or "leetcode_muted"))
		end, p.desc)
	end

	local function marker()
		return m.block(function()
			return focus() > 0.5 and "▌" or " "
		end, "leetcode_accent")
	end

	return m.flex({
		click = "double",
		on_press = press,
		on_hover = function(hovered)
			focus(hovered and 1 or 0)
		end,
		style = row,
		justify = "between",
		m.flex({
			m.block({ marker(), p.desc and marker() }),
			m.block({
				margin_left = function()
					return 1 + math.floor(slide() + 0.5)
				end,
				m.block({
					m.inline(function()
						if busy() then
							return m.inline({ m.loader({ style = "leetcode_accent" }), " " })
						end
						return m.inline(p.icon .. " ", fade(p.icon_hl or "Character"))
					end),
					p.prefix and m.inline(p.prefix .. " ", fade("leetcode_muted")),
					m.inline(p.title, fade("leetcode_strong")),
					p.nested and m.inline(" \u{eab6}", fade("leetcode_muted")),
				}),
				p.desc and m.block({ margin_left = 2, description() }),
			}),
		}),
		m.inline({ margin_right = 1, kit.Key(p.lhs) }),
	})
end)
