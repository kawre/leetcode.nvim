local Popup = require("leetcode.ui.popup")

---@class lc.ui.Console.Popup : lc.ui.Popup
---@field popup NuiPopup
---@field parent lc.ui.ConsoleLayout
local ConsolePopup = Popup:extend("LeetConsolePopup")

---@param keymaps table<string, function>
function ConsolePopup:set_keymaps(keymaps)
    for key, fn in pairs(keymaps) do
        self:map("n", key, fn, { nowait = true })
    end
end

---@param keymaps table<string, function>
function ConsolePopup:clear_keymaps(keymaps)
    for key, fn in pairs(keymaps) do
        self:map("n", key, fn, { nowait = true })
    end
end

function ConsolePopup:init(opts)
    ConsolePopup.super.init(self, opts)
    self:off({ "BufLeave", "WinLeave" })
end

---@type fun(opts: table): lc.ui.Console.Popup
local LeetConsolePopup = ConsolePopup

return LeetConsolePopup
