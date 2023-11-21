local NuiPopup = require("nui.popup")
local log = require("leetcode.logger")

---@class lc.ui.Popup : NuiPopup
---@field popup NuiPopup
---@field parent lc.ui.ConsoleLayout
---@field visible boolean
local Popup = NuiPopup:extend("LeetPopup")

function Popup:focus()
    if not vim.api.nvim_win_is_valid(self.winid) then return end
    vim.api.nvim_set_current_win(self.winid)
end

function Popup:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        Popup.super.show(self)
    end

    self.visible = true
end

function Popup:hide()
    if not self.visible then return end
    Popup.super.hide(self)
    self.visible = false
end

function Popup:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

function Popup:init(opts)
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

    Popup.super.init(self, opts)

    self.visible = false

    self:on(
        "BufUnload",
        function() log.error("Do not close `leetcode.nvim` popups. Use `q` or `Esc` instead") end
    )

    self:on({ "BufLeave", "WinLeave" }, function() self:hide() end)

    self:map("n", { "q", "<Esc>" }, function() self:hide() end)
end

---@type fun(opts: table): lc.ui.Popup
local LeetPopup = Popup

return LeetPopup
