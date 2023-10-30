local Text = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")

local log = require("leetcode.logger")
local hl = {
    ["All"] = "leetcode_all",
    ["Easy"] = "leetcode_easy",
    ["Medium"] = "leetcode_medium",
    ["Hard"] = "leetcode_hard",
}

---@class lc-menu.Solved : lc-ui.Text
local Solved = {}
Solved.__index = Solved
setmetatable(Solved, Text)

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
            idx = ({
                ["All"] = 1,
                ["Easy"] = 2,
                ["Medium"] = 3,
                ["Hard"] = 4,
            })[stat.difficulty],
        }
    end

    for diff, stat in pairs(subs) do
        local line = NuiLine()
        line:append(diff, hl[diff])

        local pad1 = (" "):rep(8 - vim.api.nvim_strwidth(diff))
        line:append(pad1)

        line:append(stat.line)

        local pad2 = (" "):rep(max_count_len + 2 - stat.line:content():len())
        line:append(pad2)

        line:append(self:progress_bar(50, stat.solved, stat.total_count, diff))

        table.insert(self.solved_lines, stat.idx, line)
    end

    self.lines = self.solved_lines
end

---@param res lc.Stats.Res
function Solved:init(res, opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Keyword",
        -- padding = {
        --     top = 4,
        --     bot = 2,
        -- },
    }, opts or {})

    self = setmetatable(Text:init({}, opts), self)
    self:handle_res(res)
    return self
end

return Solved
