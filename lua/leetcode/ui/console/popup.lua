---@class lc.Console.Popup
---@field popup NuiPopup
---@field parent lc.Console
local cpopup = {}
cpopup.__index = cpopup

function cpopup:focus()
    if not vim.api.nvim_win_is_valid(self.popup.winid) then return end
    vim.api.nvim_set_current_win(self.popup.winid)
end

return cpopup
