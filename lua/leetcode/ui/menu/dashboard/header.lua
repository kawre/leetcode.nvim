--- The top of a page of the menu: where it is, and what it can do, on one line
--- above a rule. The same on every page, so each reads as part of the menu.

local i18n = require("leetcode.i18n")
local m = require("markup")

---@class leet.ui.menu.header.action
---@field title string
---@field lhs string
---@field press function
---@field content? fun(): any shown in place of the title, such as progress

--- A press of the header: its name and key, which fill in under the cursor.
local Action = m.component(function(props)
	local hovered = m.signal(false)
	m.use_key(props.lhs, props.press, { nowait = true })

	return m.inline({
		click = "double",
		on_press = props.press,
		on_hover = hovered,
		white_space = "nowrap",
		style = function()
			return hovered() and "leetcode_tab_active" or nil
		end,
		m.inline({
			style = function()
				return hovered() and "leetcode_tab_active" or "leetcode_muted"
			end,
			function()
				local content = props.content and props.content()
				return content and m.inline({ " ", content, " " }) or (" %s "):format(props.title)
			end,
		}),
		m.inline({
			style = function()
				return hovered() and "leetcode_tab_active" or "leetcode_key"
			end,
			props.lhs .. " ",
		}),
	})
end)

---@param props { title: string, width: integer, actions: leet.ui.menu.header.action[] }
return function(props)
	return m.block({
		width = props.width,
		margin_bottom = 1,
		m.flex({
			padding = { 0, 1 },
			justify = "between",
			white_space = "nowrap",
			m.inline({
				m.inline(i18n.menu, "leetcode_muted"),
				m.inline(" › ", "leetcode_muted"),
				m.inline(props.title, "leetcode_strong"),
			}),
			m.flex({ spacing = 1, vim.tbl_map(Action, props.actions) }),
		}),
		m.block(("─"):rep(props.width), "leetcode_divider"),
	})
end
