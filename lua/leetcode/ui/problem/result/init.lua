local m = require("markup")
local Runtime = require("leetcode.ui.problem.result.runtime")
local SubmissionError = require("leetcode.ui.problem.result.submission-error")
local LimitExceed = require("leetcode.ui.problem.result.limit-exceeded")
local RuntimeError = require("leetcode.ui.problem.result.runtime.error")
local InternalError = require("leetcode.ui.problem.result.internal-error")
local CompileError = require("leetcode.ui.problem.result.compile-error")

---@param props { item: lc.interpreter_response, console: leet.problem.console }
local App = m.component(function(props)
    local item = props.item ---@type any
    local sc = item.status_code

    if sc == 10 then
        ---@cast item lc.runtime
        return Runtime({ item = item })
    elseif sc == 11 then
        ---@cast item lc.submission
        return SubmissionError({ item = item })
    elseif sc == 12 or sc == 13 or sc == 14 then
        ---@cast item lc.limit_exceeded_error
        return LimitExceed({ item = item })
    elseif sc == 15 then
        ---@cast item lc.runtime_error
        return RuntimeError({ item = item })
    elseif sc == 16 then
        ---@cast item lc.internal_error
        return InternalError({ item = item })
    elseif sc == 20 then
        ---@cast item lc.compile_error
        return CompileError({ item = item })
    else
        return "unknown runner status code: " .. sc
    end
end)

return App
