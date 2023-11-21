local NuiPopup = require("nui.popup")

---@class lc.ui.Console.Popup : lc.ui.Popup
---@field popup NuiPopup
---@field parent lc.ui.ConsoleLayout
local ConsolePopup = NuiPopup:extend("LeetConsolePopup")

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

function ConsolePopup:focus()
    if not vim.api.nvim_win_is_valid(self.winid) then return end
    vim.api.nvim_set_current_win(self.winid)
end

function ConsolePopup:init(opts)
    opts = vim.tbl_deep_extend("force", {
        focusable = true,
        border = {
            padding = {
                top = 1,
                bottom = 1,
                left = 3,
                right = 3,
            },
            style = "rounded",
        },
    }, opts or {})

    ConsolePopup.super.init(self, opts)
    self:off({ "BufLeave", "WinLeave" })
end

---@type fun(opts: table): lc.ui.Console.Popup
local LeetConsolePopup = ConsolePopup

return LeetConsolePopup
