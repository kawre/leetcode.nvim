local Padding = require("leetcode-ui.lines.padding")
local Opts = require("leetcode-ui.opts")
local Group = require("leetcode-ui.group")

local log = require("leetcode.logger")

---@class lc.on_press
---@field fn function
---@field sc string

---@class lc-ui.Layout._
---@field line_idx integer
---@field buttons lc-ui.Button[]
---@field opts lc-ui.Layout.opts

---@class lc-ui.Renderer : lc-ui.Group
---@field bufnr integer
---@field winid integer
---@field _ lc-ui.Layout._ | lc.ui.Group.params
local Renderer = Group:extend("LeetRenderer")

function Renderer:draw(component)
    self.bufnr = component.bufnr
    self.winid = component.winid

    self._.buttons = {}
    self._.line_idx = 1

    local c_ok, c = pcall(vim.api.nvim_win_get_cursor, self.winid)
    self:modifiable(function()
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
        vim.api.nvim_buf_clear_namespace(self.bufnr, -1, 0, -1)

        Renderer.super.draw(self, self, self._.opts)
    end)
    if c_ok then pcall(vim.api.nvim_win_set_cursor, self.winid, c) end
end

---@private
---
---@param fn function
function Renderer:modifiable(fn)
    local bufnr = self.bufnr
    if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then return end

    local modi = vim.api.nvim_buf_get_option(bufnr, "modifiable")
    if not modi then vim.api.nvim_buf_set_option(bufnr, "modifiable", true) end
    fn()
    if not modi then vim.api.nvim_buf_set_option(bufnr, "modifiable", false) end
end

function Renderer:clear()
    Renderer.super.clear(self)

    self._.line_idx = 1
    self._.buttons = {}
    self:modifiable(function() vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {}) end)
end

---@param val? integer Optional value to increment line index by
function Renderer:get_line_idx(val)
    local line_idx = self._.line_idx
    self._.line_idx = self._.line_idx + (val or 0)
    return line_idx
end

---@param line integer The line that the click happened
function Renderer:handle_press(line)
    if self._.buttons[line] then self._.buttons[line]:press() end
end

-- ---@param line integer
-- ---@param fn function
-- ---@param sc string shortcut
-- function Layout:set_on_press(line, fn, sc) self._.buttons[line] = { fn = fn, sc = sc } end

function Renderer:replace(items) self._.items = items end

---@param layout lc-ui.Renderer
function Renderer:set(layout) self._.items = layout._.items end

---@param components lc-ui.Lines[]
---@param opts? lc-ui.Layout.opts
function Renderer:init(components, opts)
    Renderer.super.init(self, components or {}, opts or {})

    self._.line_idx = 1
    self._.buttons = {}
end

---@type fun(components?: table[], opts?: lc-ui.Layout.opts): lc-ui.Renderer
local LeetRenderer = Renderer

return LeetRenderer
