local NuiLayout = require("nui.layout")

local log = require("leetcode.logger")

---@class lc.ui.Layout : NuiLayout
---@field visible boolean
local Layout = NuiLayout:extend("LeetLayout")

function Layout:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        Layout.super.show(self)
    end

    self.visible = true
end

function Layout:hide()
    if not self.visible then
        return
    end
    Layout.super.hide(self)
    self.visible = false
end

function Layout:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

function Layout:mount()
    Layout.super.mount(self)
    self.visible = true
end

function Layout:unmount()
    Layout.super.unmount(self)
    self.visible = false
end

function Layout:init(options, box) --
    Layout.super.init(self, options, box)

    self.visible = false
end

---@type fun(options: table, box: table): lc.ui.Renderer
local LeetLayout = Layout

return LeetLayout
