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

---@param difficulty string
---@return string
function M.diff_to_hl(difficulty)
	return difficulty_hl[difficulty:lower()]
end

return M
