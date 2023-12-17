local log = require("leetcode.logger")
local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")

---@type Path
local leetbody = config.home:joinpath(".leetbody")
leetbody:touch()

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
    local ok, err = pcall(Runner.handle, self, submit)
    if not ok then log.error(err) end
    Runner.running = false
end)

function Runner:handle(submit)
    local question = self.question

    local body = {
        lang = question.lang,
        typed_code = self.question:lines(),
        question_id = question.q.id,
    }

    local function callback(item)
        if type(item) == "boolean" and item == true then
            question.console.result:clear()
        else
            self:callback(item)
        end
    end

    if not submit then
        local di_lines = question.console.testcase:content()
        local data_input = table.concat(di_lines, "\n")
        body.data_input = data_input

        leetbody:write(vim.json.encode(body), "w")
        interpreter.interpret_solution(question.q.title_slug, leetbody:absolute(), callback)
    else
        interpreter.submit(question.q.title_slug, body, callback)
    end
end

---@param item lc.interpreter_response
function Runner:callback(item) self.question.console.result:handle(item) end

---@param question lc.ui.Question
function Runner:init(question) return setmetatable({ question = question }, self) end

return Runner
