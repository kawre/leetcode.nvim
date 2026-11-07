local m = require("markup")
local kit = require("leetcode.ui.kit")

--- A button of the bar, which marks itself as the cursor is hidden here.
local Action = m.component(function(props)
	local hovered = m.signal(false)

	m.use_key(props.lhs, props.press, { nowait = true })

	return m.inline({
		on_press = props.press,
		on_hover = hovered,
		white_space = "nowrap",
		style = function()
			return hovered() and "leetcode_tab_active" or "leetcode_tab"
		end,
		m.inline((" %s "):format(props.title)),
		m.inline({
			style = function()
				return hovered() and "leetcode_tab_active" or "leetcode_key"
			end,
			props.lhs .. " ",
		}),
	})
end)

--- The top of a page that slides in beside the dashboard.
---@param props { title: string, width: integer, actions: { title: string, lhs: string, press: function }[] }
return function(props)
	return kit.Card({
		width = props.width,
		m.flex({
			justify = "between",
			m.inline(props.title, "leetcode_strong"),
			m.flex({ spacing = 1, vim.tbl_map(Action, props.actions) }),
		}),
	})
end
