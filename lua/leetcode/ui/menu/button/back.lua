local m = require("markup")
local i18n = require("leetcode.i18n")
local Item = require("leetcode.ui.menu.item")

return m.component(function(props)
	return Item({
		icon = "\u{f053}",
		title = i18n.back,
		desc = i18n.back_desc,
		lhs = "q",
		page = props.page,
	})
end)
