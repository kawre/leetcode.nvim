--- What the dashboard shows. It lives here rather than in the cards, because the
--- cards mount again whenever the dashboard changes shape.

local m = require("markup")

---@class leet.ui.menu.data
local M = {
	streak = m.signal({}),
	daily = m.signal(nil),
	calendar = m.signal(nil),
	skills = m.signal(nil),
	languages = m.signal(nil),
}

--- Calls `done` once all of `count` callbacks came back.
---@param count integer
---@param done? function
---@return function
local function after(count, done)
	return function()
		count = count - 1
		if count == 0 and done then
			done()
		end
	end
end

--- What only the statistics page shows, so it is fetched when that opens.
---@param done? function
function M.load_details(done)
	local api = require("leetcode.api.stats")
	local finish = after(2, done)

	api.skills(function(res, err)
		finish()
		if err then
			return Markup.log.error(err)
		end
		M.skills(res)
	end)

	api.languages(function(res, err)
		finish()
		if err then
			return Markup.log.error(err)
		end
		M.languages(res ~= vim.NIL and res or {})
	end)
end

---@param done? function called once everything came back, errors included
function M.load(done)
	local api = require("leetcode.api.stats")
	local finish = after(3, done)

	api.streak(function(data, err)
		finish()
		if err then
			return Markup.log.error(err)
		end
		M.streak(data)
	end)

	api.calendar(function(data, err)
		finish()
		if err then
			return Markup.log.error(err)
		end
		M.calendar(data.calendar.submission_calendar)
	end)

	require("leetcode.api.problems").question_of_today(function(res, err)
		finish()
		if err then
			return Markup.log.error(err)
		end

		local ok, problem = pcall(function()
			return require("leetcode.cache.problems").by_slug(res.title_slug)
		end)
		M.daily(ok and problem or nil)
	end)
end

--- Fetches everything the dashboard and the statistics show.
---@param done? function
function M.update(done)
	local finish = after(3, done)
	M.load(finish)
	M.load_details(finish)
	require("leetcode.ui.menu.solved").fetch(finish)
end

return M
