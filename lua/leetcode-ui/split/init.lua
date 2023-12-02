local Renderer = require("leetcode-ui.renderer")
local NuiSplit = require("nui.split")

local log = require("leetcode.logger")

---@class lc-ui.Split : NuiSplit
---@field renderer lc-ui.Renderer
---@field visible boolean
local Split = NuiSplit:extend("LeetSplit")

function Split:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end

    self:update_renderer()
end

function Split:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        Split.super.show(self)
    end

    self:update_renderer()
    self.visible = true
end

function Split:hide()
    if not self.visible then return end
    Split.super.hide(self)

    self:update_renderer()
    self.visible = false
end

function Split:mount()
    Split.super.mount(self)

    self.visible = true
    self:update_renderer()

    self:map("n", { "q", "<Esc>" }, function() self:toggle() end)
end

function Split:map(...) self.renderer:map(...) end

function Split:unmount()
    Split.super.unmount(self)

    self:update_renderer()
    self.visible = false
end

function Split:draw()
    self:update_renderer()
    self.renderer:draw(self)
end

function Split:clear()
    self.renderer:clear()
    self:update_renderer()
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
