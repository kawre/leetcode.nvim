local utils = require("leetcode.api.rest.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local async_util = require("plenary.async.util")
local async = require("plenary.async")

---@class lc.Interpreter
local interpreter = {}

---@param question lc.QuestionResponse
---@param typed_code string
---@param data_input string
---@param callback function
function interpreter.interpret_solution(question, typed_code, data_input, callback)
    local url =
        string.format(config.domain .. "/problems/%s/interpret_solution/", question.title_slug)

    local body = {
        lang = config.user.lang,
        question_id = question.id,
        typed_code = typed_code,
        data_input = data_input,
    }

    ---@type boolean, submission
    local ok, res = pcall(utils.post, url, body)
    assert(ok)

    async.run(function() ---@diagnostic disable-line
        local noti = log.spin("PENDING"):start()

        while true do
            ---@type lc.Interpreter.Response
            local check = interpreter.check(res.interpret_id)
            noti:update(check.state)

            if check.state == "SUCCESS" then
                noti:done()
                return check
            else
                async_util.sleep(750)
            end
        end
    end, callback)
end

---@param interpret_id string
---
---@return lc.Interpreter.Response
function interpreter.check(interpret_id)
    local url = string.format(config.domain .. "/submissions/detail/%s/check/", interpret_id)

    ---@type boolean, lc.Interpreter.Response
    local ok, res = pcall(utils.get, url)
    assert(ok)

    return res
end

return interpreter
