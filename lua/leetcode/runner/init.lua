local log = require("leetcode.logger")
local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")

---@class lc.Runner
---@field question lc-ui.Question
local runner = {}
runner.__index = runner

runner.running = false

---@param submit boolean
runner.run = vim.schedule_wrap(function(self, submit)
    if runner.running then return log.warn("Runner is busy") end
    runner.running = true

    local question = self.question

    local tc_lines = vim.api.nvim_buf_get_lines(question.bufnr, 0, -1, false)
    local typed_code = table.concat(tc_lines, "\n")

    local body = {
        lang = question.lang,
        typed_code = typed_code,
        question_id = question.q.id,
    }

    local function callback(item)
        if type(item) == "boolean" then
            if item == true then
                question.console.result:clear()
            else
                runner.running = false
            end
        else
            self:callback(item)
            runner.running = false
        end
    end

    if not submit then
        local di_lines = question.console.testcase:content()
        local data_input = table.concat(di_lines, "\n")
        body.data_input = data_input

        interpreter.interpret_solution(question.q.title_slug, body, callback)
    else
        interpreter.submit(question.q.title_slug, body, callback)
    end
end)

---@private
---@param item lc.interpreter_response
function runner:callback(item) self.question.console.result:handle(item) end

---@param question lc-ui.Question
function runner:init(question) return setmetatable({ question = question }, self) end

return runner
