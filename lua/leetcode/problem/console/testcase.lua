---@class leet.problem.console.testcase
local M = Markup.object()

function M:new()
    self.win = Markup.window({
        box = "horizontal",
        border = "rounded",
        title = "Testcase",
        show = false,
    })
end

return M
