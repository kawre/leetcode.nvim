local log = require("leetcode.logger")
local Line = require("nui.line")
local Padding = require("leetcode-ui.component.padding")

---@class lc-ui.Layout
---@field components lc-ui.Component[]
---@field opts lc-ui.Layout.opts
---@field line_idx integer
---@field buttons table<integer, function>
---@field bufnr integer
---@field winid integer
local Layout = {}
Layout.__index = Layout

---@param win NuiSplit | NuiPopup | table
function Layout:draw(win)
    self.line_idx = 1
    self.bufnr = win.bufnr
    self.winid = win.winid

    local padding = self.opts.padding
    local components = vim.deepcopy(self.components)

    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then table.insert(components, 1, Padding:init(toppad)) end
    if botpad then table.insert(components, Padding:init(botpad)) end

    for _, component in pairs(components) do
        component:draw(self)
    end
end

function Layout:clear()
    self.components = {}
    self.line_idx = 1
    self.buttons = {}

    return self
end

---@param val? integer Optional value to increment line index by
function Layout:get_line_idx(val)
    local line_idx = self.line_idx
    self.line_idx = self.line_idx + (val or 1)
    return line_idx
end

---@param line integer The line that the click happend
function Layout:handle_press(line)
    if self.buttons[line] then self.buttons[line]() end
end

---@param line integer
---@param fn function
function Layout:set_on_press(line, fn) self.buttons[line] = fn end

---@param content lc-ui.Component
function Layout:append(content)
    table.insert(self.components, content)
    return self
end

---@param config? lc-ui.Layout.config
function Layout:init(config)
    config = config or {}

    local obj = setmetatable({
        components = config.components or {},
        opts = config.opts or {
            padding = {},
        },
        line_idx = 1,
        buttons = {},
        bufnr = 0,
        winid = 0,
    }, self)

    return obj
end

return Layout
