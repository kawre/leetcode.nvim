local NuiPopup = require("nui.popup")
local Renderer = require("leetcode-ui.renderer")
local config = require("leetcode.config")
local keys = config.user.keys

local log = require("leetcode.logger")

---@class lc.ui.Popup : NuiPopup
---@field visible boolean
---@field renderer lc.ui.Renderer
local Popup = NuiPopup:extend("LeetPopup")

function Popup:_open_window()
    Popup.super._open_window(self)
    self:update_renderer()
end

function Popup:_close_window()
    Popup.super._close_window(self)
    self:update_renderer()
end

function Popup:_buf_create()
    Popup.super._buf_create(self)
    self:update_renderer()
end

function Popup:_buf_destory()
    Popup.super._buf_destory(self)
    self:update_renderer()
end

function Popup:focus()
    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_set_current_win(self.winid)
    end
end

function Popup:clear() --
    self.renderer:clear()
end

function Popup:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        Popup.super.show(self)
    end

    self.visible = true
end

function Popup:unmount()
    self:clear()
    Popup.super.unmount(self)

    self.visible = false
end

function Popup:map(...)
    self.renderer:map(...)
end

function Popup:mount()
    Popup.super.mount(self)

    self.visible = true

    self:on({ "BufLeave", "WinLeave" }, function()
        self:handle_leave()
    end)
    self:map("n", keys.toggle, function()
        self:hide()
    end)
end

function Popup:hide()
    if not self.visible then
        return
    end
    Popup.super.hide(self)

    self.visible = false
end

function Popup:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

function Popup:handle_leave()
    self:hide()
end

function Popup:draw()
    self.renderer:draw(self)
end

function Popup:update_renderer()
    self.renderer.bufnr = self.bufnr
    self.renderer.winid = self.winid
end

function Popup:init(opts)
    local options = vim.tbl_deep_extend("force", {
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
        buf_options = {
            filetype = config.name,
        },
    }, opts or {})

    self.renderer = self.renderer or Renderer()
    self.visible = false

    Popup.super.init(self, options)
end

---@type fun(opts: table): lc.ui.Popup
local LeetPopup = Popup

return LeetPopup
