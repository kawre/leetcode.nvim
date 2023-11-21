local Lines = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local utils = require("leetcode.api.utils")
local statistics = require("leetcode.api.statistics")
local t = require("leetcode.translator")

local log = require("leetcode.logger")
local hl = {
    ["All"] = "leetcode_all",
    ["Easy"] = "leetcode_easy",
    ["Medium"] = "leetcode_medium",
    ["Hard"] = "leetcode_hard",
}

---@class lc-menu.Solved : lc-ui.Text
local Solved = Lines:extend("LeetSolved")

---@return NuiLine
function Solved:progress_bar(width, solved, total_count, difficulty)
    local line = NuiLine()
    local solved_len = math.ceil(width * (solved / total_count))

    for _ = 1, solved_len do
        line:append("󰝤", hl[difficulty])
    end

    for _ = solved_len, width do
        line:append("󰝤", hl[difficulty] .. "_alt")
    end

    return line
end

---@param res lc.Stats.Res
function Solved:handle_res(res)
    self.stats = res
    self.solved_lines = {}

    local subs = {}

    local max_count_len = 0
    for _, stat in ipairs(res.submit_stats.acSubmissionNum) do
        local total_count = vim.tbl_filter(
            function(c) return c.difficulty == stat.difficulty end,
            self.stats.questions_count
        )[1].count

        local solved_line = NuiLine()
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

        local line = NuiLine()
        line:append(diff_str, hl[diff])

        local pad1 = (" "):rep(pad_len + 2 - vim.api.nvim_strwidth(diff_str))
        line:append(pad1)

        line:append(stat.line)

        local pad2 = (" "):rep(max_count_len + 2 - stat.line:content():len())
        line:append(pad2)

        line:append(self:progress_bar(50, stat.solved, stat.total_count, diff))

        table.insert(self.solved_lines, line)
    end

    self.lines = self.solved_lines
    _Lc_Menu:draw()
end

function Solved:init()
    local opts = {
        position = "center",
        hl = "Keyword",
    }

    Solved.super.init(self, opts)
    self:append(t("Loading..."))

    statistics.solved(function(res, err)
        if err then log.err(err) end
        self:handle_res(res)
    end)
end

---@type fun(): lc-menu.Solved
local LeetSolved = Solved

return LeetSolved
