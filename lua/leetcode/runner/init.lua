local log = require("leetcode.logger")
local rest = require("leetcode.rest")
local utils = require("leetcode.runner.utils")

---@class lc.Runner
local runner = {}
runner.__index = runner

function runner:run()
    local question = problems[curr_question]

    local lines = vim.api.nvim_buf_get_lines(question.bufnr, 0, -1, false)
    local typed_code = utils.to_typed_code(lines)

    local data_input = table.concat(question.testcases, "\n")

    local res = rest.interpreter.interpret_solution(question.q, typed_code, data_input)
end

function runner:submit() end

function runner:init() return setmetatable({}, self) end

return runner
