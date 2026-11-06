local m = require("markup")
local Popup = require("leetcode.ui.popup")
local Spinner = require("leetcode.logger.spinner")
local config = require("leetcode.config")
local stats_api = require("leetcode.api.stats")
local t = require("leetcode.translator")

local function Language(res)
	local lang = Leet.util.get_lang_by_name(res.lang)
	local spans = {}

	if lang then
		spans[1] = m.inline(lang.icon .. " " .. lang.lang, lang.hl or "leetcode_code")
	else
		spans[1] = m.inline(res.lang, "leetcode_code")
	end

	spans[2] = m.inline(" - ", "leetcode_list")

	if config.translator then
		spans[3] = m.inline("解题数", "leetcode_alt")
		spans[4] = m.inline(" " .. res.problems_solved)
	else
		local label = res.problems_solved == 1 and " problem solved" or " problems solved"
		spans[3] = m.inline(tostring(res.problems_solved))
		spans[4] = m.inline(label, "leetcode_alt")
	end

	return m.block(spans)
end

local Languages = m.component(function()
	local data = m.signal(nil)

	local spinner = Spinner:start("fetching user languages", "dot")
	stats_api.languages(function(res, err)
		if err then
			spinner:error(err.msg)
		else
			data(res)
			spinner:success("languages fetched")
		end
	end)

	return m.block({
		padding = { 1, 2 },
		function()
			local res = data()
			if not res or res == vim.NIL then
				return nil
			end

			table.sort(res, function(a, b)
				return a.problems_solved > b.problems_solved
			end)
			return m.vflex({ spacing = 1, vim.tbl_map(Language, res) })
		end,
	})
end)

return Popup({
	title = t("Languages"),
	width = 75,
	height = 0.5,
	content = function()
		return Languages()
	end,
})
