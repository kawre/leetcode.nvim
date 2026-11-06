--- Helpers for working on the plugin, enabled with the `dev` option.

local config = require("leetcode.config")

---@class leet.dev
local M = {}

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")

--- Where fetched problems go. Ignored by git.
M.problems_dir = root .. "/.dev/problems"

local function write(path, content)
	local file = assert(io.open(path, "w"))
	file:write(content)
	file:close()
end

--- Keeps the raw html of a fetched problem, to have real input for the renderer.
--- Never gets in the way of opening the problem.
---@param q lc.question_res
function M.save_problem(q)
	if not config.user.dev then
		return
	end

	local ok, err = pcall(function()
		vim.fn.mkdir(M.problems_dir, "p")

		local name = ("%s/%s.%s"):format(M.problems_dir, q.frontend_id, q.title_slug)
		if type(q.content) == "string" then
			write(name .. ".html", q.content)
		end
		if type(q.translated_content) == "string" then
			write(name .. ".cn.html", q.translated_content)
		end
	end)

	if not ok then
		require("leetcode.logger").warn("Failed to save problem html: " .. tostring(err))
	end
end

return M
