---@class leet.ui.browser.filters
---@field difficulty "all"|"easy"|"medium"|"hard"
---@field status "all"|"ac"|"notac"|"todo"
---@field free boolean only problems that do not need premium
---@field query string

---@class leet.ui.browser.filter
local M = {}

--- Splits a query into title words and an optional leading ID such as `1.`.
local function parse_query(query)
	local id, title = query:match("^%s*(%d+)%.%f[%s%z](.*)$")
	return vim.split((title or query):lower(), "%s+", { trimempty = true }), id
end

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

--- Where the words of a query first appear in a title, as byte ranges that do
--- not overlap, in order. Each one is `{ from, to }`, both inclusive. Only the
--- first, since a short word would otherwise light up half the title.
---@param title string
---@param query string
---@return integer[][]
function M.ranges(title, query)
	local lower = title:lower()
	local covered = {}
	local words = parse_query(query)

	for _, word in ipairs(words) do
		local start, finish = lower:find(word, 1, true)
		for byte = start or 1, finish or 0 do
			covered[byte] = true
		end
	end

	local ranges = {}
	for byte = 1, #title do
		if covered[byte] then
			local last = ranges[#ranges]
			if last and last[2] == byte - 1 then
				last[2] = byte
			else
				ranges[#ranges + 1] = { byte, byte }
			end
		end
	end
	return ranges
end

--- A title split into spans, with what the query matched highlighted.
---@param title string
---@param query string
---@return { [1]: string, [2]?: string }[]
function M.highlight(title, query)
	local spans, at = {}, 1
	for _, range in ipairs(M.ranges(title, query)) do
		if range[1] > at then
			spans[#spans + 1] = { title:sub(at, range[1] - 1) }
		end
		spans[#spans + 1] = { title:sub(range[1], range[2]), "MarkupPickerMatch" }
		at = range[2] + 1
	end
	if at <= #title then
		spans[#spans + 1] = { title:sub(at) }
	end
	return spans
end

---@param problems leet.cache.problem[]
---@param filters leet.ui.browser.filters
---@return leet.cache.problem[]
function M.apply(problems, filters)
	local words, id = parse_query(filters.query)

	return vim.tbl_filter(function(problem)
		return (not id or tostring(problem.frontend_id) == id)
			and (filters.difficulty == "all" or problem.difficulty:lower() == filters.difficulty)
			and (filters.status == "all" or problem.status == filters.status)
			and not (filters.free and problem.paid_only)
			and matches(problem, words)
	end, problems)
end

return M
