---@class leet.problem.console.result
local M = Markup.object()

function M:new()
    self.win = Markup.window({
        box = "horizontal",
        title = "Results",
        border = "rounded",
        show = false,
    })
end

return M
