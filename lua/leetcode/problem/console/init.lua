local Result = require("leetcode.problem.console.result")
local Testcase = require("leetcode.problem.console.testcase")

---@class leet.problem.console
local M = Markup.object()

---@param problem leet.problem
function M:new(problem)
    self.question = problem

    self.result = Result()
    self.testcase = Testcase()

    self.layout = Markup.layout({
        wins = {
            ["result"] = self.result.win,
            ["testcase"] = self.testcase.win,
        },
        layout = {
            box = "horizontal",
            focusable = true,
            position = "bottom",
            height = 0.3,
            { win = "testcase", width = 0.4 },
            { win = "result" },
        },
    })
    -- self.renderer = Markup.renderer({
    --     relative = "editor",
    --     position = "bottom",
    --     height = 0.3,
    --     enter = false,
    --     focusable = true,
    -- })
end

return M
