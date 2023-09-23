local log = require("leetcode.logger")
local rest = require("leetcode.api.rest")
local utils = require("leetcode.runner.utils")

---@class lc.Runner
---@field question lc.Question
local runner = {}
runner.__index = runner

function runner:run()
    local question = self.question

    local di_lines = question.console.testcase:content()
    local data_input = table.concat(di_lines, "\n")

    local tc_lines = vim.api.nvim_buf_get_lines(question.bufnr, 0, -1, false)
    local typed_code = utils.to_typed_code(tc_lines)

    local res = rest.interpreter.interpret_solution(
        question.q,
        typed_code,
        data_input,
        function(item) self:callback(item) end
    )

    return res
end

---@private
---@param item lc.Interpreter.Response
function runner:callback(item) self.question.console.result:handle(item) end

function runner:submit() end

---@param question lc.Question
function runner:init(question) return setmetatable({ question = question }, self) end

return runner
