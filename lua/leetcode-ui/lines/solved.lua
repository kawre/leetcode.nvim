local Lines = require("leetcode-ui.lines")
local Line = require("leetcode-ui.line")
local utils = require("leetcode-ui.utils")
local Spinner = require("leetcode.logger.spinner")
local statistics = require("leetcode.api.statistics")
local t = require("leetcode.translator")

local log = require("leetcode.logger")

---@class lc.ui.Solved : lc.ui.Lines
local Solved = Lines:extend("LeetSolved")

---@return NuiLine
function Solved:progress_bar(width, solved, total_count, difficulty)
    local line = Line()
    local solved_len = math.ceil(width * (solved / total_count))

    for _ = 1, solved_len do
        line:append("󰝤", utils.diff_to_hl(difficulty))
    end

    for _ = solved_len, width do
        line:append("󰝤", utils.diff_to_hl(difficulty) .. "_alt")
    end

    return line
end

---@param res lc.Stats.Res
function Solved:handle_res(res)
    self:clear()

    local subs = {}

    local max_count_len = 0
    for _, stat in ipairs(res.submit_stats.acSubmissionNum) do
        local total_count = vim.tbl_filter(function(c)
            return c.difficulty == stat.difficulty
        end, res.questions_count)[1].count

        local solved_line = Line()
        solved_line:append(tostring(stat.count))
        solved_line:append(("/%d"):format(total_count), "leetcode_alt")
        max_count_len = math.max(solved_line:content():len(), max_count_len)

        subs[stat.difficulty] = {
            total_count = total_count,
            solved = stat.count,
            line = solved_line,
        }
    end

    local order = { "All", "Easy", "Medium", "Hard" }
    local pad_len = 0
    for _, diff in ipairs(order) do
        pad_len = math.max(pad_len, vim.api.nvim_strwidth(t(diff)))
    end

    for _, diff in ipairs(order) do
        local stat = subs[diff]
        local diff_str = t(diff)

        self:append(diff_str, utils.diff_to_hl(diff))

        local pad1 = (" "):rep(pad_len + 2 - vim.api.nvim_strwidth(diff_str))
        self:append(pad1)

        self:append(stat.line)

        local pad2 = (" "):rep(max_count_len + 2 - stat.line:content():len())
        self:append(pad2)

        self:append(self:progress_bar(50, stat.solved, stat.total_count, diff))

        self:endl()
    end

    _Lc_state.menu:draw()
end

function Solved:update()
    local spinner = Spinner:init("updating solved problems...")
    statistics.solved(function(res, err)
        if err then
            spinner:stop(err.msg, false)
        else
            spinner:stop("solved problems updated", true, { timeout = 200 })
            self:handle_res(res)
        end
    end)
end

function Solved:fetch()
    statistics.solved(function(res, err)
        if err then
            return log.err(err)
        end
        self:handle_res(res)
    end)
end

function Solved:init()
    local opts = {
        position = "center",
        hl = "Keyword",
    }

    Solved.super.init(self, {}, opts)

    self:append(t("Loading..."))
    self:fetch()
end

---@type fun(): lc.ui.Solved
local LeetSolved = Solved

return LeetSolved
