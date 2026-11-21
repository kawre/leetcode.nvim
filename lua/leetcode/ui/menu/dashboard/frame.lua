--- A card of the dashboard. Its top and bottom rows are its padding, and hold
--- the corners that frame it while it is selected, like the viewfinder of a
--- camera, so nothing moves when they come and go.

local m = require("markup")

---@class leet.ui.menu.framed
---@field selected fun(): boolean
---@field width integer the outer width
---@field style any
---@field on_press? function
---@field on_hover? fun(hovered: boolean)
---@field children any[]

---@param props leet.ui.menu.framed
return function(props)
	local function corner(char)
		return m.inline(function()
			return props.selected() and char or " "
		end, "leetcode_accent")
	end

	local function edge(left, right)
		return m.flex({ justify = "between", white_space = "nowrap", corner(left), corner(right) })
	end

	return m.block({
		width = props.width,
		style = props.style,
		click = "double",
		on_press = props.on_press,
		on_hover = props.on_hover,
		edge("┌", "┐"),
		m.block({ padding = { 0, 2 }, children = props.children }),
		edge("└", "┘"),
	})
end
