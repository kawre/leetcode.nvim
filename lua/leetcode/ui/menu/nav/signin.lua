local m = require("markup")
local Items = require("leetcode.ui.menu.items")
local Item = require("leetcode.ui.menu.item")

return m.component(function()
	local cmd = require("leetcode.cmd")

	return Items({
		Item({
			icon = "\u{f0306}",
			title = "Sign in",
			desc = "paste your session cookie",
			lhs = "i",
			on_submit = cmd.cookie_prompt,
		}),
		Item({
			icon = "\u{f0a48}",
			title = "Quit",
			desc = "close leetcode.nvim",
			lhs = "q",
			on_submit = function()
				require("leetcode").stop()
			end,
		}),
	})
end)
