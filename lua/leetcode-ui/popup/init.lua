local NuiPopup = require("nui.popup")
local Renderer = require("leetcode-ui.renderer")
local config = require("leetcode.config")

local log = require("leetcode.logger")

---@class lc-ui.Popup : NuiPopup
---@field visible boolean
---@field renderer lc-ui.Renderer
---@field keymaps table<string|string[], string>
local Popup = NuiPopup:extend("LeetPopup")

function Popup:focus()
    if not vim.api.nvim_win_is_valid(self.winid) then return end
    vim.api.nvim_set_current_win(self.winid)
end

function Popup:clear_keymaps()
    for key, mode in pairs(self.keymaps) do
        self:unmap(mode, key)
    end
    self.keymaps = {}
end

function Popup:clear() --
    self:clear_keymaps()
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

function Popup:mount()
    Popup.super.mount(self)
    self.visible = true
    self:on({ "BufLeave", "WinLeave" }, function() self:handle_leave() end)
    self:map("n", { "q", "<Esc>" }, function() self:hide() end)
end

function Popup:hide()
    if not self.visible then return end
    Popup.super.hide(self)
    self.visible = false
end

function Popup:map(mode, key, handler, opts, ___force___)
    if opts and opts.clear == true then
        self.keymaps[key] = mode
        opts.clear = nil
    end

    Popup.super.map(self, mode, key, handler, opts, ___force___)
end

function Popup:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

function Popup:handle_leave() self:hide() end

function Popup:draw() self.renderer:draw(self) end

function Popup:init(opts)
    self.keymaps = {}

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
    Popup.super.init(self, options)

    self.renderer = self.renderer or Renderer()
    self.visible = false
    self.keymaps = {}
end

---@type fun(opts: table): lc-ui.Popup
local LeetPopup = Popup

return LeetPopup
