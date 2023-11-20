local NuiPopup = require("nui.popup")
local log = require("leetcode.logger")

---@class lc.ui.Popup : NuiPopup
---@field popup NuiPopup
---@field parent lc.ui.ConsoleLayout
local Popup = NuiPopup:extend("LeetPopup")

function Popup:focus()
    if not vim.api.nvim_win_is_valid(self.winid) then return end
    vim.api.nvim_set_current_win(self.winid)
end

function Popup:show()
    if self._.mounted then
        Popup.super.show(self)
    else
        Popup.super.mount(self)
    end

    self._.opened = true
end

function Popup:hide()
    Popup.super.hide(self)
    self._.opened = false
end

function Popup:toggle()
    if self._.opened then
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

    self._.opened = false

    self:on(
        "BufUnload",
        function() log.error("Do not close `leetcode.nvim` popups. Use `q` or `Esc` instead") end
    )

    self:map("n", { "q", "<Esc>" }, function() self:hide() end)
end

---@type fun(opts: table): lc.ui.Popup
local LeetPopup = Popup

return LeetPopup
