local log = require("leetcode.logger")
local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")

---@type Path
local leetbody = config.storage.cache:joinpath("body")
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

    local ok, err = pcall(Runner.handle, self, submit)
    if not ok then
        self:stop()
        log.error(err)
    end
end)

Runner.stop = function() Runner.running = false end

function Runner:handle(submit)
    Runner.running = true
    local question = self.question

    local body = {
        lang = question.lang,
        typed_code = self.question:lines(submit),
        question_id = question.q.id,
        data_input = not submit and table.concat(question.console.testcase:content(), "\n") or nil,
    }

    local function callback(item)
        if type(item) == "boolean" then
            if item then
                question.console.result:clear()
            else
                self:stop()
            end
        else
            self:callback(item)
        end
    end

    leetbody:write(vim.json.encode(body), "w")
    if not submit then
        interpreter.interpret_solution(question.q.title_slug, leetbody:absolute(), callback)
    else
        interpreter.submit(question.q.title_slug, leetbody:absolute(), callback)
    end
end

---@param item lc.interpreter_response
function Runner:callback(item)
    self:stop()
    self.question.console.result:handle(item)
end

---@param question lc.ui.Question
function Runner:init(question) return setmetatable({ question = question }, self) end

return Runner
