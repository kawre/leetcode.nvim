local Padding = require("leetcode-ui.component.padding")
local Object = require("nui.object")

local log = require("leetcode.logger")

---@class lc.on_press
---@field fn function
---@field sc string

---@class lc-ui.Layout._
---@field components lc-ui.Text[]
---@field line_idx integer
---@field buttons lc-ui.Button[]
---@field opts lc-ui.Layout.opts

---@class lc-ui.Layout
---@field bufnr integer
---@field winid integer
---@field _ lc-ui.Layout._
local Layout = Object("LeetLayout")

function Layout:draw()
    local c_ok, c = pcall(vim.api.nvim_win_get_cursor, self.winid)

    self._.line_idx = 1
    self._.buttons = {}

    local padding = self._.opts.padding
    local components = self._.components

    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then table.insert(components, 1, Padding(toppad)) end
    if botpad then table.insert(components, Padding(botpad)) end

    self:modifiable(function()
        vim.api.nvim_buf_clear_namespace(self.bufnr, -1, 0, -1)
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})

        for _, component in pairs(components) do
            component:draw(self)
        end
    end)

    if c_ok then pcall(vim.api.nvim_win_set_cursor, self.winid, c) end
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
    self._.components = {}
    self._.line_idx = 1
    self._.buttons = {}

    self:modifiable(function() vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {}) end)
end

---@param val? integer Optional value to increment line index by
function Layout:get_line_idx(val)
    local line_idx = self._.line_idx
    self._.line_idx = self._.line_idx + (val or 0)
    return line_idx
end

---@param line integer The line that the click happened
function Layout:handle_press(line)
    if self._.buttons[line] then self._.buttons[line]:press() end
end

-- ---@param line integer
-- ---@param fn function
-- ---@param sc string shortcut
-- function Layout:set_on_press(line, fn, sc) self._.buttons[line] = { fn = fn, sc = sc } end

---@param content lc-ui.Text
function Layout:append(content)
    table.insert(self._.components, content)
    return self
end

---@param components lc-ui.Text[]
---@param opts? lc-ui.Layout.opts
function Layout:init(components, opts)
    opts = vim.tbl_deep_extend("force", {
        bufnr = 0,
        winid = 0,
    }, opts or {})

    self._ = {
        components = components or {},
        line_idx = 1,
        buttons = {},
        opts = opts,
        bufnr = opts.bufnr,
        winid = opts.winid,
    }
    self.bufnr = opts.bufnr
    self.winid = opts.winid
end

---@type fun(components: lc-ui.Text, opts?: lc-ui.Layout.opts): lc-ui.Layout
local LeetLayout = Layout

return LeetLayout
