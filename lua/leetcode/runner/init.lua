local log = require("leetcode.logger")

local utils = require("leetcode.runner.utils")
local config = require("leetcode.config")

local interpreter = require("leetcode.api.interpreter")

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

    local body = {
        lang = config.user.lang,
        data_input = data_input,
        typed_code = typed_code,
        question_id = question.q.id,
    }

    interpreter.interpret_solution(
        question.q.title_slug,
        body,
        function(item) self:callback(item) end
    )
end

---@private
---@param item interpreter_response
function runner:callback(item) self.question.console.result:handle(item) end

function runner:submit() end

---@param question lc.Question
function runner:init(question) return setmetatable({ question = question }, self) end

return runner
