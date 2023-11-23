local log = require("leetcode.logger")
local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")

---@class lc.Runner
---@field question lc-ui.Question
local runner = {}
runner.__index = runner

---@param submit? boolean
function runner:run(submit)
    local question = self.question
    if config.user.console.open_on_runcode then question.console:show() end

    vim.schedule(function()
        local tc_lines = vim.api.nvim_buf_get_lines(question.bufnr, 0, -1, false)
        local typed_code = table.concat(tc_lines, "\n")

        local body = {
            lang = question.lang,
            typed_code = typed_code,
            question_id = question.q.id,
        }

        local function callback(item) self:callback(item) end

        if not submit then
            local di_lines = question.console.testcase:content()
            local data_input = table.concat(di_lines, "\n")
            body.data_input = data_input

            interpreter.interpret_solution(question.q.title_slug, body, callback)
        else
            interpreter.submit(question.q.title_slug, body, callback)
        end
    end)
end

---@private
---@param item lc.interpreter_response
function runner:callback(item) self.question.console.result:handle(item) end

---@param question lc-ui.Question
function runner:init(question) return setmetatable({ question = question }, self) end

return runner
