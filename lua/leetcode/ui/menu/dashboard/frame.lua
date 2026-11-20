--- Corners around what is selected, like the viewfinder of a camera. They take
--- a cell of their own on every side, so nothing moves when they come and go.

local m = require("markup")

---@param props { selected: fun(): boolean, width: integer, [1]: any }
return function(props)
	local function corner(char)
		return m.inline(function()
			return props.selected() and char or " "
		end, "leetcode_accent")
	end

	local function edge(left, right)
		return m.flex({
			width = props.width + 2,
			justify = "between",
			white_space = "nowrap",
			corner(left),
			corner(right),
		})
	end

	return m.block({
		width = props.width + 2,
		edge("┌", "┐"),
		m.block({ padding = { 0, 1 }, props[1] }),
		edge("└", "┘"),
	})
end
