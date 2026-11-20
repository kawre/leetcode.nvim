local m = require("markup")
local i18n = require("leetcode.i18n")
local Items = require("leetcode.ui.menu.items")
local Item = require("leetcode.ui.menu.item")
local BackButton = require("leetcode.ui.menu.button.back")

return m.component(function()
	local cmd = require("leetcode.cmd")

	return Items({
		Item({
			icon = "\u{f16ec}",
			title = i18n.cookie,
			desc = i18n.cookie_desc,
			lhs = "u",
			on_submit = cmd.cookie_prompt,
		}),
		Item({
			icon = "\u{f16ea}",
			title = i18n.sign_out,
			desc = i18n.sign_out_desc,
			lhs = "d",
			on_submit = cmd.sign_out,
		}),
		BackButton({ page = "menu" }),
	})
end)
