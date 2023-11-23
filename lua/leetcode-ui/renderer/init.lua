local Padding = require("leetcode-ui.lines.padding")
local Object = require("nui.object")

local log = require("leetcode.logger")

---@class lc.on_press
---@field fn function
---@field sc string

---@class lc-ui.Layout._
---@field items lc-ui.Lines[]
---@field line_idx integer
---@field buttons lc-ui.Button[]
---@field opts lc-ui.Layout.opts

---@class lc-ui.Renderer
---@field bufnr integer
---@field winid integer
---@field _ lc-ui.Layout._
local Renderer = Object("LeetRenderer")

function Renderer:draw(component)
    local opts = self._.opts
    self.bufnr = component.bufnr
    self.winid = component.winid

    local c_ok, c = pcall(vim.api.nvim_win_get_cursor, self.winid)

    self._.buttons = {}
    self._.line_idx = 1

    local padding = opts.padding
    local items = self._.items

    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then table.insert(items, 1, Padding(toppad)) end
    if botpad then table.insert(items, Padding(botpad)) end

    self:modifiable(function()
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
        vim.api.nvim_buf_clear_namespace(self.bufnr, -1, 0, -1)

        for _, item in pairs(items) do
            item:draw(self, opts)
        end
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
    self._.items = {}
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

function Renderer:set_opts(opts) self._.opts = vim.tbl_deep_extend("force", self._.opts, opts or {}) end

-- ---@param line integer
-- ---@param fn function
-- ---@param sc string shortcut
-- function Layout:set_on_press(line, fn, sc) self._.buttons[line] = { fn = fn, sc = sc } end

---@param content lc-ui.Lines
function Renderer:append(content)
    table.insert(self._.items, content)
    return self
end

---@param item any
function Renderer:insert(item)
    table.insert(self._.items, item)
    return self
end

function Renderer:replace(items) self._.items = items end

---@param layout lc-ui.Renderer
function Renderer:set(layout) self._.items = layout._.items end

---@param components lc-ui.Lines[]
---@param opts? lc-ui.Layout.opts
function Renderer:init(components, opts)
    local options = vim.tbl_deep_extend("force", {}, opts or {})

    self._ = {
        items = components or {},
        line_idx = 1,
        buttons = {},
        opts = options,
    }
end

---@type fun(components?: table[], opts?: lc-ui.Layout.opts): lc-ui.Renderer
local LeetRenderer = Renderer

return LeetRenderer
