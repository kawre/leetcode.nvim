local Popup = require("leetcode-ui.popup")
local log = require("leetcode.logger")

---@class lc.ui.Console.Popup : lc.ui.Popup
---@field console lc.ui.Console
local ConsolePopup = Popup:extend("LeetConsolePopup")

---@param keymaps table<string|string[], function>
function ConsolePopup:set_keymaps(keymaps)
    for key, fn in pairs(keymaps) do
        self:map("n", key, fn, { nowait = true })
    end
end

---@param keymaps table<string, function>
function ConsolePopup:clear_keymaps(keymaps)
    for key, _ in pairs(keymaps) do
        self:unmap("n", key)
    end
end

function ConsolePopup:handle_leave()
    vim.schedule(function()
        local curr_bufnr = vim.api.nvim_get_current_buf()
        for _, p in pairs(self.console.popups) do
            if p.bufnr == curr_bufnr then return end
        end
        self.console:hide()
    end)
end

function ConsolePopup:init(parent, opts)
    ConsolePopup.super.init(self, opts)

    self.console = parent
end

---@type fun(opts: table): lc.ui.Console.Popup
local LeetConsolePopup = ConsolePopup

return LeetConsolePopup
