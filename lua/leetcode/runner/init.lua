local log = require("leetcode.logger")
local interpreter = require("leetcode.api.interpreter")
local config = require("leetcode.config")
local Judge = require("leetcode.logger.spinner.judge")

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
    if Runner.running then
        return log.warn("Runner is busy")
    end

    local ok, err = pcall(Runner.handle, self, submit)
    if not ok then
        self:stop()
        log.error(err)
    end
end)

Runner.stop = function()
    Runner.running = false
end

function Runner:handle(submit)
    Runner.running = true
    local question = self.question

    local body = {
        lang = question.lang,
        typed_code = self.question:lines(submit),
        question_id = question.q.id,
        data_input = not submit and question.console.testcase:content(),
    }

    local judge = Judge:init()
    local function callback(item, state, err)
        if err or item then
            self:stop()
        end

        if item then
            judge:stop(item.status_msg, item._.success)
        elseif state then
            judge:from_state(state)
        elseif err then
            judge:stop(err.msg or "Something went wrong", false)
        end

        if item then
            question.console.result:handle(item)
        end
    end

    leetbody:write(vim.json.encode(body), "w")
    interpreter.run(submit, question, leetbody:absolute(), callback)
end

---@param question lc.ui.Question
function Runner:init(question)
    return setmetatable({ question = question }, self)
end

return Runner
