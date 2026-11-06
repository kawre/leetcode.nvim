local m = require("markup")
local statistics = require("leetcode.api.stats")
local Spinner = require("leetcode.logger.spinner")
local t = require("leetcode.translator")
local ui = require("leetcode.ui.util")

local BAR_WIDTH = 50

local data = m.signal(nil)

---@class leet.ui.solved
local M = {}

function M.fetch()
	statistics.solved(function(res, err)
		if err then
			return Markup.log.error(err)
		end
		data(res)
	end)
end

function M.update()
	local spinner = Spinner:start("updating solved problems")
	statistics.solved(function(res, err)
		if err then
			spinner:error(err.msg)
		else
			spinner:success("solved problems updated")
			data(res)
		end
	end)
end

local function bar(solved, total, difficulty)
	local filled = math.ceil(BAR_WIDTH * (solved / total))
	local hl = ui.diff_to_hl(difficulty)
	return {
		m.inline(("󰝤"):rep(filled), hl),
		m.inline(("󰝤"):rep(BAR_WIDTH - filled + 1), hl .. "_alt"),
	}
end

local function rows(res)
	local stats = {}
	local count_width = 0

	for _, stat in ipairs(res.submit_stats.acSubmissionNum) do
		local total = vim.tbl_filter(function(c)
			return c.difficulty == stat.difficulty
		end, res.questions_count)[1].count

		stats[stat.difficulty] = { solved = stat.count, total = total }
		count_width = math.max(count_width, #("%d/%d"):format(stat.count, total))
	end

	local order = { "All", "Easy", "Medium", "Hard" }
	local label_width = 0
	for _, difficulty in ipairs(order) do
		label_width = math.max(label_width, vim.api.nvim_strwidth(t(difficulty)))
	end

	return vim.tbl_map(function(difficulty)
		local stat = stats[difficulty]
		local label = t(difficulty)
		local count = ("/%d"):format(stat.total)
		local used = #tostring(stat.solved) + #count

		return m.block({
			white_space = "nowrap",
			m.inline(label, ui.diff_to_hl(difficulty)),
			m.inline((" "):rep(label_width + 2 - vim.api.nvim_strwidth(label))),
			m.inline(tostring(stat.solved)),
			m.inline(count, "leetcode_alt"),
			m.inline((" "):rep(count_width + 2 - used)),
			bar(stat.solved, stat.total, difficulty),
		})
	end, order)
end

M.Solved = m.component(function()
	if not data() then
		M.fetch()
	end

	return m.block({
		width = "fit",
		function()
			local res = data()
			return res and m.block({ width = "fit", rows(res) }) or m.block(t("Loading..."), "Keyword")
		end,
	})
end)

return M
