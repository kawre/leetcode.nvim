local log = require("leetcode.logger")
local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")

---@class lc.Runner
---@field question lc.ui.Question
local Runner = {}
Runner.__index = Runner

Runner.running = false

---@param self lc.Runner
---@param submit boolean
Runner.run = vim.schedule_wrap(function(self, submit)
    if Runner.running then return log.warn("Runner is busy") end
    Runner.running = true

    local question = self.question

    local body = {
        lang = question.lang,
        typed_code = self.question:lines(),
        question_id = question.q.id,
    }

    local function callback(item)
        if type(item) == "boolean" then
            if item == true then
                question.console.result:clear()
            else
                Runner.running = false
            end
        else
            self:callback(item)
            Runner.running = false
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
function Runner:callback(item) self.question.console.result:handle(item) end

---@param question lc.ui.Question
function Runner:init(question) return setmetatable({ question = question }, self) end

return Runner
