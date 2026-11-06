local m = require("markup")
local Popup = require("leetcode.ui.popup")
local Spinner = require("leetcode.logger.spinner")
local config = require("leetcode.config")
local stats_api = require("leetcode.api.stats")
local ui = require("leetcode.ui.util")

local function Group(name, skills)
	table.sort(skills, function(a, b)
		return a.problems_solved > b.problems_solved
	end)

	local rows = {
		m.block({
			m.inline(config.icons.square, ui.diff_to_hl(name)),
			m.inline(" " .. name),
		}),
	}

	for _, skill in ipairs(skills) do
		table.insert(
			rows,
			m.block({
				m.inline(skill.tag, "leetcode_code"),
				m.inline((" x%d"):format(skill.problems_solved), "leetcode_alt"),
			})
		)
	end

	return m.block(rows)
end

local Skills = m.component(function()
	local data = m.signal(nil)

	local spinner = Spinner:start("fetching user skills", "dot")
	stats_api.skills(function(res, err)
		if err then
			spinner:error(err.msg)
		else
			data(res)
			spinner:success("skills fetched")
		end
	end)

	return m.block({
		padding = { 1, 2 },
		spacing = 1,
		function()
			local res = data()
			if not res then
				return nil
			end

			local groups = {}
			for _, key in ipairs({ "advanced", "intermediate", "fundamental" }) do
				table.insert(groups, Group(key, res[key] or {}))
			end
			return m.vflex({ spacing = 1, groups })
		end,
	})
end)

return Popup({
	title = "Skills",
	width = 75,
	height = 0.5,
	content = function()
		return Skills()
	end,
})
