--- What the lit card or tile does, on one line below it.

local i18n = require("leetcode.i18n")
local m = require("markup")
local kit = require("leetcode.ui.kit")
local focus = require("leetcode.ui.menu.dashboard.focus")

---@param width integer
return function(width)
	return m.block({
		width = width,
		function()
			local current = focus.current()
			if not current or not current.detail then
				return m.block(" ")
			end
			-- The same inset as the headings around it.
			return m.flex({
				padding = { 0, 1 },
				justify = "between",
				white_space = "nowrap",
				m.inline({
					m.inline(kit.icons.select .. " ", "leetcode_accent"),
					m.inline(kit.truncate(current.title, 24), "leetcode_strong"),
					m.inline("  " .. current.detail, "leetcode_muted"),
				}),
				m.inline({ kit.Key("<CR>"), m.inline(" " .. i18n.open_hint, "leetcode_muted") }),
			})
		end,
	})
end
