local m = require("markup")
local Result = require("leetcode.ui.problem.result")

---@class leet.problem.console.result
---@overload fun(): leet.problem.console.result
local M = Markup.object()

---@param console leet.problem.console
function M:new(console)
    self.console = console
    self.win = Markup.window({
        box = "horizontal",
        title = "Results",
        border = "rounded",
        show = false,
    })
    -- self.win = self.renderer.win
end

function M:clear()
    vim.api.nvim_buf_set_lines(self.win.buf, 0, -1, false, {})
end

function M:handle(item)
    -- self.renderer:render({
    -- 	m.block("123")
    -- })
    local renderer = Markup.renderer({ show = false })
    renderer.win:show()
    renderer:render(Result({ item = item, console = self.console }))
end

return M
