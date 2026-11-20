local m = require("markup")
local i18n = require("leetcode.i18n")
local Items = require("leetcode.ui.menu.items")
local Item = require("leetcode.ui.menu.item")

return m.component(function()
	local cmd = require("leetcode.cmd")

	return Items({
		Item({
			icon = "\u{f0306}",
			title = i18n.sign_in,
			desc = i18n.sign_in_desc,
			lhs = "i",
			on_submit = cmd.cookie_prompt,
		}),
		Item({
			icon = "\u{f0a48}",
			title = i18n.quit,
			desc = i18n.quit_desc,
			lhs = "q",
			on_submit = function()
				require("leetcode").stop()
			end,
		}),
	})
end)
