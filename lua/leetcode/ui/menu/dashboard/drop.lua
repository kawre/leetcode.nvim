--- Pages that change by dropping: the page leaving falls away, faster and
--- faster, into the dark below, and the moment it is gone the new one rises
--- quickly into its place. One after the other, so the two never overlap.

local m = require("markup")

local animate = Markup.animate

--- How long the fall takes.
local FALL = 220
--- How long the new page takes to settle, from how many rows below.
local RISE = 180
local RISE_FROM = 2

--- Slow at first, then ever faster, as a fall is.
local function falling(t)
	return t * t * t
end

---@class leet.ui.menu.drop.entry
---@field id integer
---@field key any
---@field first boolean the page shown first, which makes no entrance
---@field leaving fun(value?: boolean): boolean
---@field shown fun(value?: boolean): boolean whether it is in, which waits for the fall

---@param props { key: fun(): any, render: fun(key: any): any, depth: fun(): integer, on_arrived?: fun() }
--- `on_arrived` is called once the new page is in place.
return m.component(function(props)
	local pages = m.signal({}) ---@type leet.ui.menu.drop.entry[]
	local last_id = 0

	local function remove(id)
		local rest = vim.tbl_filter(function(page)
			return page.id ~= id
		end, m.untrack(pages))
		pages(rest)

		-- Once nothing is falling, the newest page comes in.
		local falling = vim.iter(rest):any(function(page)
			return m.untrack(page.leaving)
		end)
		if not falling and rest[#rest] then
			rest[#rest].shown(true)
		end
	end

	m.effect(function()
		local key = props.key()
		m.untrack(function()
			local list = pages()
			local current = list[#list]
			if current and current.key == key and not current.leaving() then
				return
			end
			for _, page in ipairs(list) do
				page.leaving(true)
			end
			last_id = last_id + 1
			local next = vim.list_extend(vim.list_slice(list), {
				{
					id = last_id,
					key = key,
					first = current == nil,
					leaving = m.signal(false),
					shown = m.signal(current == nil),
				},
			})
			pages(next)
		end)
	end)

	local Page = m.component(function(p)
		local entry = p.entry ---@type leet.ui.menu.drop.entry
		local top = animate.value(entry.first and 0 or RISE_FROM, { step = 1 })

		m.effect(function()
			if entry.shown() and not entry.first then
				m.untrack(function()
					top(0, { duration = RISE, easing = "out_cubic", done = props.on_arrived })
				end)
			end
		end)

		m.effect(function()
			if entry.leaving() then
				m.untrack(function()
					top(props.depth(), {
						duration = FALL,
						delay = 0,
						easing = falling,
						done = function()
							remove(entry.id)
						end,
					})
				end)
			end
		end)

		return m.block({
			-- Out of the flow once it falls, so the new page takes its place.
			position = function()
				return entry.leaving() and "absolute" or "relative"
			end,
			top = function()
				return math.floor(top() + 0.5)
			end,
			left = 0,
			right = 0,
			m.show(entry.shown, function()
				return props.render(entry.key)
			end),
		})
	end)

	return m.block({
		position = "relative",
		overflow = "hidden",
		-- Room to fall through, down to the bottom of the window.
		min_height = props.depth,
		m.each(pages, function(entry)
			return Page({ entry = entry })
		end, {
			key = function(entry)
				return entry.id
			end,
		}),
	})
end)
