---@class leet.ui.browser.filters
---@field difficulty "all"|"easy"|"medium"|"hard"
---@field status "all"|"ac"|"notac"|"todo"
---@field free boolean only problems that do not need premium
---@field query string

---@class leet.ui.browser.filter
local M = {}

--- A query matches on the number, or on all of its words in the title.
---@param problem leet.cache.problem
---@param words string[]
---@return boolean
local function matches(problem, words)
	local title = (problem.title .. " " .. (problem.title_cn or "")):lower()
	local id = tostring(problem.frontend_id)

	for _, word in ipairs(words) do
		if id ~= word and not title:find(word, 1, true) then
			return false
		end
	end
	return true
end

---@param problems leet.cache.problem[]
---@param filters leet.ui.browser.filters
---@return leet.cache.problem[]
function M.apply(problems, filters)
	local words = vim.split(filters.query:lower(), "%s+", { trimempty = true })

	return vim.tbl_filter(function(problem)
		return (filters.difficulty == "all" or problem.difficulty:lower() == filters.difficulty)
			and (filters.status == "all" or problem.status == filters.status)
			and not (filters.free and problem.paid_only)
			and matches(problem, words)
	end, problems)
end

return M
