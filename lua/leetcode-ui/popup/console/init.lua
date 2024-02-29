local Popup = require("leetcode-ui.popup")
local log = require("leetcode.logger")

---@class lc.ui.Console.Popup : lc.ui.Popup
---@field console lc.ui.Console
local ConsolePopup = Popup:extend("LeetConsolePopup")

ConsolePopup.handle_leave = vim.schedule_wrap(function(self)
    local curr_bufnr = vim.api.nvim_get_current_buf()
    for _, p in pairs(self.console.popups) do
        if p.bufnr == curr_bufnr then
            return
        end
    end
    self.console:hide()
end)

function ConsolePopup:init(parent, opts)
    ConsolePopup.super.init(self, opts)

    self.console = parent
end

---@type fun(opts: table): lc.ui.Console.Popup
local LeetConsolePopup = ConsolePopup

return LeetConsolePopup
