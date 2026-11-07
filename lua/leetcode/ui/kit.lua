--- The pieces every screen is built from, so they all speak the same language.

local m = require("markup")

local animate = Markup.animate

---@class leet.ui.kit
local M = {}

M.icons = {
	fire = "\u{f0238}",
	check = "\u{f00c}",
	cross = "\u{f00d}",
	search = "\u{f0349}",
	clock = "\u{f0150}",
	memory = "\u{f035b}",
	calendar = "\u{f00f6}",
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

--- A rounded label.
---@param text string
---@param kind string one of `easy`, `medium`, `hard`
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
---@param props { value: fun(): number, width: integer, style: string, delay?: number, instant?: boolean }
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
		track = "leetcode_track",
	})
end

return M
