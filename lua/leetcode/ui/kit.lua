--- The pieces every screen is built from, so they all speak the same language.

local i18n = require("leetcode.i18n")
local m = require("markup")

local animate = Markup.animate

---@class leet.ui.kit
local M = {}

M.icons = {
	add = "\u{f0415}",
	fire = "\u{f0238}",
	check = "\u{f00c}",
	cross = "\u{f00d}",
	search = "\u{f0349}",
	clock = "\u{f0150}",
	memory = "\u{f035b}",
	calendar = "\u{f00f6}",
	arrow_up = "\u{f005d}",
	resume = "↻",
	select = "\u{f0cfd}",
	thumb_up = "\u{f164}",
	thumb_down = "\u{f165}",
	bulb = "\u{f06e8}",
	trophy = "\u{f0538}",
	code = "\u{f0174}",
	dot = "\u{f0766}",
	pill_left = "\u{e0b6}",
	pill_right = "\u{e0b4}",
}

--- A color of a highlight, as a number.
---@param group string
---@param attribute "fg"|"bg"
---@return integer
function M.color(group, attribute)
	return animate.color(group, attribute) or 0
end

--- A surface that holds related things. Its half cell edges keep the padding on
--- all sides equal.
---@param props table
function M.Card(props)
	local card = vim.tbl_extend("keep", props, {
		style = "leetcode_surface",
		border = "half",
		padding = { 0, 2 },
	})

	-- Widths are the outer size here, so that cards line up with each other.
	if card.width then
		card.width = card.width - card.padding[2] * 2
	end
	return m.block(card)
end

--- A card the cursor can stop on, which lifts while it is there and is framed
--- by corners, as on the dashboard. Pressing it does nothing unless it says so.
---@param props table
function M.HoverCard(props)
	local Frame = require("leetcode.ui.menu.dashboard.frame")
	local focus = m.animated(0, { duration = 110 })
	local hovered = m.signal(false)
	local tint = Markup.animate.tint(
		{ bg = M.color("leetcode_surface", "bg") },
		{ bg = M.color("leetcode_row_active", "bg") },
		focus
	)

	local children = {}
	for _, child in ipairs(props) do
		children[#children + 1] = child
	end

	return Frame({
		selected = hovered,
		width = props.width,
		style = tint,
		on_press = props.on_press or function() end,
		on_hover = function(on)
			hovered(on)
			focus(on and 1 or 0)
		end,
		children = children,
	})
end

--- Cuts text to a width, which shows with an ellipsis.
---@param text string
---@param width integer
---@return string
function M.truncate(text, width)
	if vim.api.nvim_strwidth(text) <= width then
		return text
	end

	local chars = vim.fn.split(text, "\\zs")
	local result, used = {}, 0
	for _, char in ipairs(chars) do
		used = used + vim.api.nvim_strwidth(char)
		if used > width - 1 then
			break
		end
		result[#result + 1] = char
	end
	return table.concat(result) .. "…"
end

--- Something that is on its way.
---@param text? string
function M.Loading(text)
	return m.inline({
		m.loader({ style = "leetcode_accent" }),
		m.inline(" " .. (text or i18n.loading), "leetcode_muted"),
	})
end

--- A rounded label.
---@param text string
---@param kind string one of `easy`, `medium`, `hard`, `accent`
function M.Pill(text, kind)
	local group = "leetcode_pill_" .. kind:lower()
	return m.inline({
		white_space = "nowrap",
		m.inline(M.icons.pill_left, group .. "_cap"),
		m.inline(text, group),
		m.inline(M.icons.pill_right, group .. "_cap"),
	})
end

--- The key that triggers something.
---@param lhs string
function M.Key(lhs)
	return m.inline(lhs, "leetcode_key")
end

---@class leet.ui.task
---@field cancelled fun(): boolean whether what started it is gone, and the answer is not wanted
---@field done fun() ends it

--- Work that answers later, such as a fetch, tied to the component starting
--- it. Returns whether it is under way, and `start(run)`, which calls
--- `run(task)` unless it already is. Once the component is gone the task is
--- cancelled, and nothing should be done with what comes back.
---@return fun(): boolean busy
---@return fun(run: fun(task: leet.ui.task)) start
function M.use_task()
	local busy = m.signal(false)
	local alive = true
	m.on_cleanup(function()
		alive = false
	end)

	local task = {
		cancelled = function()
			return not alive
		end,
		done = function()
			if alive then
				busy(false)
			end
		end,
	}

	return busy,
		function(run)
			if m.untrack(busy) then
				return
			end
			busy(true)
			run(task)
		end
end

--- Muted text with elements in it, such as keys, which fill its `%s` in order.
--- A translation is free to put them where it reads well.
---@param text string
---@param ... any
function M.Sentence(text, ...)
	local parts = { ... }
	local pieces = vim.split(text, "%s", { plain = true })
	local children = {}
	for i, piece in ipairs(pieces) do
		if piece ~= "" then
			children[#children + 1] = m.inline(piece, "leetcode_muted")
		end
		if i < #pieces then
			children[#children + 1] = parts[i]
		end
	end
	return m.inline(children)
end

--- A number that counts up to `value`.
---@param value fun(): number
---@param opts? { delay?: number, duration?: number, instant?: boolean } `instant`
--- starts at the value, so only later changes count
---@return fun(): number
function M.counter(value, opts)
	local instant = opts and opts.instant
	local shown = m.animated(instant and (m.untrack(value) or 0) or 0, {
		duration = opts and opts.duration or 900,
		delay = opts and opts.delay,
		easing = "out_quint",
	})

	m.effect(function()
		shown(value() or 0)
	end)
	return shown
end

local DIGITS = {
	["0"] = { "█▀█", "█ █", "█▄█" },
	["1"] = { "▀█ ", " █ ", "▄█▄" },
	["2"] = { "▀▀█", "█▀▀", "█▄▄" },
	["3"] = { "▀▀█", " ▀█", "▄▄█" },
	["4"] = { "█ █", "▀▀█", "  █" },
	["5"] = { "█▀▀", "▀▀█", "▄▄█" },
	["6"] = { "█▀▀", "█▀█", "█▄█" },
	["7"] = { "▀▀█", "  █", "  █" },
	["8"] = { "█▀█", "█▀█", "█▄█" },
	["9"] = { "█▀█", "▀▀█", "▄▄█" },
}

--- Text of a number three rows tall.
---@param number integer
---@return string[]
function M.big_number(number)
	local rows = { {}, {}, {} }
	for digit in tostring(number):gmatch("%d") do
		for i, row in ipairs(DIGITS[digit]) do
			table.insert(rows[i], row)
		end
	end
	return vim.tbl_map(function(row)
		return table.concat(row, " ")
	end, rows)
end

--- A number three rows tall.
---@param props { value: fun(): number, style?: string }
function M.BigNumber(props)
	local function row(i)
		return m.block(function()
			return M.big_number(math.floor(props.value() + 0.5))[i]
		end, props.style)
	end

	return m.block({ white_space = "nowrap", width = "fit", row(1), row(2), row(3) })
end

--- A bar that fills up when it appears.
---@param props { value: fun(): number, width: integer, style: string, track?: string, delay?: number, instant?: boolean }
function M.Bar(props)
	local start = props.instant and (m.untrack(props.value) or 0) or 0
	local filled = m.animated(start, { duration = 800, delay = props.delay, easing = "out_cubic" })

	m.effect(function()
		filled(props.value() or 0)
	end)

	return m.progress({
		value = filled,
		width = props.width,
		style = props.style,
		track = props.track or "leetcode_track",
	})
end

return M
