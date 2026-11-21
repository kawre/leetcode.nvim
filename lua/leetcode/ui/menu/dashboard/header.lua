--- Where the menu is, Menu › page, and what the page can do, on one line just
--- above the page. It never moves: only the page below it changes.

local i18n = require("leetcode.i18n")
local m = require("markup")

--- Pages named for the code rather than for reading.
local TITLES = {
	["menu.problems"] = "problems",
	["menu.statistics"] = "statistics",
	["menu.cookie"] = "account",
}

---@class leet.ui.menu.header.action
---@field title string
---@field lhs string
---@field content? fun(): any shown in place of the title, such as progress

---@param props { width: fun(): integer }
return m.component(function(props)
	return m.vflex({
		align = "center",
		function()
			local width = props.width()
			local page = Leet.menu.page()
			local title = TITLES[page]

			local actions = {}
			for _, action in ipairs(Leet.menu.actions()) do
				actions[#actions + 1] = m.inline({
					m.inline(function()
						local content = action.content and action.content()
						return content or action.title
					end, "leetcode_muted"),
					m.inline(" " .. action.lhs, "leetcode_key"),
				})
			end

			return m.block({
				width = width,
				m.flex({
					padding = { 0, 1 },
					justify = "between",
					white_space = "nowrap",
					m.inline({
						m.inline(i18n.menu, title and "leetcode_muted" or "leetcode_strong"),
						title and m.inline(" › ", "leetcode_muted"),
						title and m.inline(i18n[title], "leetcode_strong"),
					}),
					m.flex({ spacing = 3, actions }),
				}),
				m.block(("─"):rep(width), "leetcode_divider"),
				m.block(" "),
			})
		end,
	})
end)
