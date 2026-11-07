--- What the user worked on lately. Solutions are files named after their problem,
--- so their times already tell, with nothing else to keep up to date.

local config = require("leetcode.config")

---@class leet.ui.menu.recent
local M = {}

---@class leet.ui.menu.recent.item
---@field problem leet.cache.problem
---@field time integer when it was last saved
---@field ext string

--- The newest file of each problem.
---@return table<string, { time: integer, ext: string }>
local function solutions()
	local home = config.storage.home:absolute()
	local newest = {}

	for name, kind in vim.fs.dir(home) do
		-- Some languages add a part between the two, as in `1.two-sum.python2.py`.
		local slug = name:match("^%d+%.([%w%-]+)%.")
		local ext = name:match("%.(%w+)$")
		if kind == "file" and slug and ext then
			local stat = vim.uv.fs_stat(home .. "/" .. name)
			if stat and (not newest[slug] or stat.mtime.sec > newest[slug].time) then
				newest[slug] = { time = stat.mtime.sec, ext = ext }
			end
		end
	end

	return newest
end

---@param limit integer
---@return leet.ui.menu.recent.item[]
function M.list(limit)
	local ok, problems = pcall(function()
		return require("leetcode.cache.problems").get()
	end)
	if not ok then
		return {}
	end

	local files = solutions()
	local items = {}
	for _, problem in ipairs(problems) do
		local file = files[problem.title_slug]
		if file then
			items[#items + 1] = { problem = problem, time = file.time, ext = file.ext }
		end
	end

	table.sort(items, function(a, b)
		return a.time > b.time
	end)
	return vim.list_slice(items, 1, limit)
end

--- How long ago a moment was, in the largest unit that fits.
---@param time integer
---@param now? integer
---@return string
function M.ago(time, now)
	local seconds = (now or os.time()) - time

	for _, unit in ipairs({ { 604800, "w" }, { 86400, "d" }, { 3600, "h" }, { 60, "m" } }) do
		if seconds >= unit[1] then
			return ("%d%s ago"):format(math.floor(seconds / unit[1]), unit[2])
		end
	end
	return "just now"
end

return M
