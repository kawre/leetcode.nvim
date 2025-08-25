---@class leet.problem.description
local M = Markup.object()

---@param problem leet.problem
function M:new(problem)
    self.problem = problem
    self.win = Markup.window({
        relative = "win",
        position = "left",
        width = 0.4,
        enter = false,
        focusable = true,
    })

    self.renderer = Markup.renderer(self.win)
    local parsed = Markup.parser(problem.problem.content, "html"):parse()
    Markup.log(parsed)
    self.renderer:render(parsed)
end

return M
