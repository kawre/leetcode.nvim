local NuiLayout = require("nui.layout")

local log = require("leetcode.logger")

---@class lc-ui.Layout : NuiLayout
local Layout = NuiLayout:extend("LeetLayout")

function Layout:init(options, box) --
    Layout.super.init(self, options, box)
end

---@type fun(options: table, box: table): lc-ui.Renderer
local LeetLayout = Layout

return LeetLayout
