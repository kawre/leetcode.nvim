---@class leet.ui.util
local M = {}

local difficulty_hl = {
	all = "leetcode_all",

	easy = "leetcode_easy",
	fundamental = "leetcode_easy",

	medium = "leetcode_medium",
	intermediate = "leetcode_medium",

	hard = "leetcode_hard",
	advanced = "leetcode_hard",
}

--- The one marker of everything that collapses.
---@param open boolean
---@return string
function M.chevron(open)
	return open and "\u{eab4} " or "\u{eab6} "
end

---@param difficulty string
---@return string
function M.diff_to_hl(difficulty)
	return difficulty_hl[difficulty:lower()]
end

return M
