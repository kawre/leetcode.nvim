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
    self.renderer = Markup.renderer(self.win)
end

function M:clear()
    vim.api.nvim_buf_set_lines(self.win.buf, 0, -1, false, {})
end

---@param item lc.interpreter_response
function M:handle(item)
    Markup.log(item.status_code)
    item._.params = self.console.problem.problem.meta_data.params
    self.renderer:render(Result({ item = item, console = self.console }))
end

return M
