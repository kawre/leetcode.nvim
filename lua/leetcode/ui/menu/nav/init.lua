local m = require("markup")

local Nav = m.component(function(props)
	-- Rows only make an entrance on a new page, not when the dashboard reflows.
	local mounted = false

	return m.block({
		function()
			Leet.menu.rows = 0
			Leet.menu.rows_enter = mounted or not Leet.menu.settled()
			mounted = true
			return require("leetcode.ui.menu.nav." .. Leet.menu.home_page())({
				width = props.width,
				columns = props.columns,
			})
		end,
	})
end)

return Nav
