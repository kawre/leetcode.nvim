---@class leet.ui.result.diff
local M = {}

--- Past this there is too much to read it character by character.
local MAX_CHARS = 4000

---@param chars string[]
---@param changed table<integer, boolean>
---@return { [1]: string, [2]: boolean }[]
local function runs(chars, changed)
	local result = {}
	for i, char in ipairs(chars) do
		local is_changed = changed[i] or false
		local last = result[#result]
		if last and last[2] == is_changed then
			last[1] = last[1] .. char
		else
			result[#result + 1] = { char, is_changed }
		end
	end
	return result
end

--- Splits two strings into runs of text, each marked if it differs from the other.
---@param a string
---@param b string
---@return { [1]: string, [2]: boolean }[] a
---@return { [1]: string, [2]: boolean }[] b
function M.split(a, b)
	if a == b or #a > MAX_CHARS or #b > MAX_CHARS then
		return { { a, false } }, { { b, false } }
	end

	local chars_a, chars_b = vim.fn.split(a, "\\zs"), vim.fn.split(b, "\\zs")
	local hunks = vim.text.diff(
		table.concat(chars_a, "\n") .. "\n",
		table.concat(chars_b, "\n") .. "\n",
		{ result_type = "indices" }
	)

	local changed_a, changed_b = {}, {}
	for _, hunk in ipairs(hunks) do
		for i = hunk[1], hunk[1] + hunk[2] - 1 do
			changed_a[i] = hunk[2] > 0 or nil
		end
		for i = hunk[3], hunk[3] + hunk[4] - 1 do
			changed_b[i] = hunk[4] > 0 or nil
		end
	end

	return runs(chars_a, changed_a), runs(chars_b, changed_b)
end

return M
