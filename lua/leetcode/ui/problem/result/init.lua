local m = require("markup")
local Runtime = require("leetcode.ui.problem.result.runtime")
local SubmissionError = require("leetcode.ui.problem.result.submission-error")
local LimitExceed = require("leetcode.ui.problem.result.limit-exceeded")
local RuntimeError = require("leetcode.ui.problem.result.runtime-error")
local InternalError = require("leetcode.ui.problem.result.internal-error")
local CompileError = require("leetcode.ui.problem.result.compile-error")

local App = m.component(function(props)
    local item = props.item
    local sc = item.status_code

    if sc == 10 then
        return Runtime({ item = item, console = props.console })
    elseif sc == 11 then
        return SubmissionError({ item = item })
    elseif sc == 12 or sc == 13 or sc == 14 then
        return LimitExceed({ item = item })
    elseif sc == 15 then
        return RuntimeError({ item = item })
    elseif sc == 16 then
        return InternalError({ item = item })
    elseif sc == 20 then
        return CompileError({ item = item })
    else
        return "unknown runner status code: " .. sc
    end
end)

return App
