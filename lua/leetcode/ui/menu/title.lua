local m = require("markup")
local i18n = require("leetcode.i18n")

--- Pages named for the code rather than for reading.
local names = { signin = "welcome", loading = "welcome", cookie = "account" }

return m.component(function()
	local function titles()
		local page = Leet.menu.home_page()
		local titles = {}
		local parts = vim.split(page, ".", { plain = true })

		for i, title in ipairs(parts) do
			title = i18n[names[title] or title]
			local last = i == #parts
			table.insert(titles, m.inline(title, last and "leetcode_strong" or "leetcode_muted"))

			if not last then
				table.insert(titles, m.inline(" \u{eab6} ", "leetcode_muted"))
			end
		end

		return titles
	end

	return m.flex({ margin_bottom = 1, padding = { 0, 2 }, titles })
end)
