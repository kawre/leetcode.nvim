---@param leet.problem.description
local M = Markup.object()

---@param problem leet.problem
function M:new(problem)
    self.problem = problem
    self.renderer = Markup.renderer({
        relative = "win",
        position = "left",
        width = 0.4,
        enter = false,
        focusable = true,
    })
end

return M
