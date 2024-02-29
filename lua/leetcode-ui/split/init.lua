local Renderer = require("leetcode-ui.renderer")
local NuiSplit = require("nui.split")
local config = require("leetcode.config")
local keys = config.user.keys

local log = require("leetcode.logger")

---@class lc-ui.Split : NuiSplit
---@field renderer lc.ui.Renderer
---@field visible boolean
local Split = NuiSplit:extend("LeetSplit")

function Split:_open_window()
    Split.super._open_window(self)
    self:update_renderer()
end

function Split:_close_window()
    Split.super._close_window(self)
    self:update_renderer()
end

function Split:_buf_create()
    Split.super._buf_create(self)
    self:update_renderer()
end

function Split:_buf_destory()
    Split.super._buf_destory(self)
    self:update_renderer()
end

function Split:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

function Split:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        Split.super.show(self)
    end

    self.visible = true
end

function Split:hide()
    if not self.visible then
        return
    end
    Split.super.hide(self)

    self.visible = false
end

function Split:mount()
    Split.super.mount(self)

    self.visible = true

    self:map("n", keys.toggle, function()
        self:toggle()
    end)
end

function Split:map(...)
    self.renderer:map(...)
end

function Split:unmount()
    Split.super.unmount(self)

    self.visible = false
end

function Split:draw()
    self.renderer:draw(self)
end

function Split:clear()
    self.renderer:clear()
end

function Split:update_renderer()
    self.renderer.bufnr = self.bufnr
    self.renderer.winid = self.winid
end

function Split:init(opts) --
    local options = vim.tbl_deep_extend("force", {
        relative = "editor",
        enter = false,
        focusable = true,
    }, opts or {})

    self.renderer = self.renderer or Renderer()
    self.visible = false

    Split.super.init(self, options)
end

---@type fun(opts?: nui_split_options): lc-ui.Split
local LeetSplit = Split

return LeetSplit
