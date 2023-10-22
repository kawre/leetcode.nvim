local Padding = require("leetcode-ui.component.padding")

---@class lc.on_press
---@field fn function
---@field sc string

---@class lc-ui.Layout
---@field components lc-ui.Component[]
---@field opts lc-ui.Layout.opts
---@field line_idx integer
---@field buttons table<integer, lc.on_press>
---@field bufnr integer
---@field winid integer
local Layout = {}
Layout.__index = Layout

---@param win? NuiSplit|NuiPopup|table
function Layout:draw(win)
    self.line_idx = 1

    if win then
        self.bufnr = win.bufnr
        self.winid = win.winid
    end

    local padding = self.opts.padding
    local components = self.components

    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then table.insert(components, 1, Padding:init(toppad)) end
    if botpad then table.insert(components, Padding:init(botpad)) end

    self:modifiable(function()
        vim.api.nvim_buf_clear_namespace(self.bufnr, -1, 0, -1)
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})

        for _, component in pairs(components) do
            component:draw(self)
        end
    end)
end

---@private
---
---@param fn function
function Layout:modifiable(fn)
    local bufnr = self.bufnr
    local modi = vim.api.nvim_buf_get_option(bufnr, "modifiable")
    if not modi then vim.api.nvim_buf_set_option(bufnr, "modifiable", true) end
    fn()
    if not modi then vim.api.nvim_buf_set_option(bufnr, "modifiable", false) end
end

function Layout:clear()
    self.components = {}
    self.line_idx = 1
    self.buttons = {}

    self:modifiable(function() vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {}) end)
end

---@param val? integer Optional value to increment line index by
function Layout:get_line_idx(val)
    local line_idx = self.line_idx
    self.line_idx = self.line_idx + (val or 0)
    return line_idx
end

---@param line integer The line that the click happened
function Layout:handle_press(line)
    if self.buttons[line] then self.buttons[line].fn() end
end

---@param line integer
---@param fn function
---@param sc string shortcut
function Layout:set_on_press(line, fn, sc) self.buttons[line] = { fn = fn, sc = sc } end

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
        bufnr = config.bufnr or 0,
        winid = config.winid or 0,
    }, self)

    return obj
end

return Layout
