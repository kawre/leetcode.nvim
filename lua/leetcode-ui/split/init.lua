local Object = require("nui.object")
local Renderer = require("leetcode-ui.renderer")
local NuiSplit = require("nui.split")

---@class lc-ui.Split : NuiSplit
---@field renderer lc-ui.Renderer
---@field visible boolean
local Split = NuiSplit:extend("LeetSplit")

function Split:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end

    self.visible = not self.visible
end

function Split:mount()
    Split.super.mount(self)

    self.renderer.winid = self.winid
    self.renderer.bufnr = self.bufnr

    self:map("n", { "q", "<Esc>" }, function() self:toggle() end)
end

function Split:draw() self.renderer:draw(self) end

function Split:init(opts) --
    local options = vim.tbl_deep_extend("force", {
        relative = "editor",
        enter = false,
        focusable = true,
    }, opts or {})

    self.renderer = self.renderer or Renderer()

    Split.super.init(self, options)
end

---@type fun(opts?: nui_split_options): lc-ui.Split
local LeetSplit = Split

return LeetSplit
