local markup = require("markup")
local log = require("leetcode.logger")

---@class leet.ui.Problem.Window : markup.Window
---@field protected super markup.Window
---@field problem leet.ui.Problem
local ProblemWindow = markup.Window:extend("leet.problem.window")

function ProblemWindow:init(...)
    ProblemWindow.super.init(self, ...)
    self.problem = self._.problem
end

---@param inclusive? boolean
---@return integer, integer, string[]
function ProblemWindow:code_range(inclusive)
    local lines = self:buf_get_lines(0, -1, false)
    local start_i, end_i

    for i, line in ipairs(lines) do
        if line:match("@leet start") then
            start_i = i + (inclusive and 0 or 1)
        elseif line:match("@leet end") then
            end_i = i - (inclusive and 0 or 1)
        end
    end

    return start_i, end_i, lines
end

---@param submit boolean
function ProblemWindow:code_lines(submit)
    local start_i, end_i, lines = self:code_range()

    start_i = start_i or 1
    end_i = end_i or #lines

    local prefix = not submit and ("\n"):rep(start_i - 1) or ""
    return prefix .. table.concat(lines, "\n", start_i, end_i)
end

function ProblemWindow:fold_range()
    local start_i, _, lines = self:code_range(true)
    if start_i == nil or start_i <= 1 then
        return
    end

    local i = start_i - 1
    while lines[i] == "" do
        i = i - 1
    end

    if 1 < i then
        return i
    end
end

---@param code? string
function ProblemWindow:set_code_lines(code)
    if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
        return
    end

    pcall(vim.cmd.undojoin)
    local s_i, e_i, lines = self:code_range()
    s_i = s_i or 1
    e_i = e_i or #lines
    code = code and code or (self.problem:snippet(true) or "")
    vim.api.nvim_buf_set_lines(self.bufnr, s_i - 1, e_i, false, vim.split(code, "\n"))
end

function ProblemWindow:reset_code_lines()
    local new_lines = self.problem:snippet(true) or ""

    -- vim.schedule(function()
    --     log.info("Previous code found and reset\nTo undo, simply press `u`")
    -- end)

    self:set_code_lines(new_lines)
end

function ProblemWindow:buf_open()
    ProblemWindow.super.buf_open(self)

    local i = self:fold_range()
    if i then
        vim.api.nvim_buf_call(self.bufnr, function()
            vim.cmd(("%d,%dfold"):format(1, i)) ---@diagnostic disable-line: param-type-mismatch
        end)
    end

    -- if existed and self.cache.status == "ac" then
    -- self:reset_code_lines()
    -- end
end

return ProblemWindow
