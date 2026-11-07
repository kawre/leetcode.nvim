--- What the dashboard shows. It lives here rather than in the cards, because the
--- cards mount again whenever the dashboard changes shape.

local m = require("markup")

---@class leet.ui.menu.data
local M = {
	streak = m.signal({}),
	daily = m.signal(nil),
	calendar = m.signal(nil),
}

function M.load()
	local api = require("leetcode.api.stats")

	api.streak(function(data, err)
		if err then
			return Markup.log.error(err)
		end
		M.streak(data)
	end)

	api.calendar(function(data, err)
		if err then
			return Markup.log.error(err)
		end
		M.calendar(data.calendar.submission_calendar)
	end)

	require("leetcode.api.problems").question_of_today(function(res, err)
		if err then
			return Markup.log.error(err)
		end

		local ok, problem = pcall(function()
			return require("leetcode.cache.problems").by_slug(res.title_slug)
		end)
		M.daily(ok and problem or nil)
	end)
end

return M
