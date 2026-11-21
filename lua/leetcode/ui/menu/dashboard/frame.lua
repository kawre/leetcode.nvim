--- A card of the dashboard. While it is selected, a slim accent spine runs down
--- its left edge, in a column of its padding, so nothing moves when it comes
--- and goes.

local m = require("markup")

---@class leet.ui.menu.framed
---@field selected fun(): boolean
---@field width integer the outer width
---@field style any
---@field on_press? function
---@field on_hover? fun(hovered: boolean)
---@field children any[]

--- Only the left side is drawn, so only the last character counts.
local SPINE = { chars = "       ▎" }

---@param props leet.ui.menu.framed
return function(props)
	return m.flex({
		width = props.width,
		style = props.style,
		click = "double",
		on_press = props.on_press,
		on_hover = props.on_hover,
		-- The column stretches to the height of the card, whatever it holds.
		m.show(props.selected, function()
			return m.block({
				border = SPINE,
				border_sides = { "left" },
				border_style = "leetcode_accent",
			})
		end, function()
			return m.block({ width = 1 })
		end),
		m.block({ width = props.width - 4, padding = { 1, 2, 1, 1 }, children = props.children }),
	})
end
