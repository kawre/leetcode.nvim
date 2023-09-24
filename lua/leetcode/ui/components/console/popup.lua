---@class lc.Console.Popup
---@field popup NuiPopup
---@field parent lc.Console
local popup = {}
popup.__index = popup

function popup:keymaps(keymaps)
    for key, fn in pairs(keymaps) do
        self.popup:map("n", key, fn, { nowait = true })
    end

    return self
end

return popup
