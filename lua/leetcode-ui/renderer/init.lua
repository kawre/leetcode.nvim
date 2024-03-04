local Group = require("leetcode-ui.group")
local config = require("leetcode.config")
local keys = config.user.keys

local log = require("leetcode.logger")

---@class lc.on_press
---@field fn function
---@field sc string

---@class lc-ui.Layout._
---@field line_idx integer
---@field buttons lc.ui.Button[]
---@field opts lc.ui.opts
---@field keymaps table[]

---@class lc.ui.Renderer : lc.ui.Group
---@field bufnr integer
---@field winid integer
---@field _ lc-ui.Layout._ | lc.ui.Group.params
local Renderer = Group:extend("LeetRenderer")

function Renderer:draw(component)
    self.bufnr = component.bufnr
    self.winid = component.winid

    if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
        return
    end

    self:map("n", keys.confirm, function()
        self:handle_press()
    end)

    self:clear_keymaps()
    self._.buttons = {}
    self._.line_idx = 1

    local c_ok, c = pcall(vim.api.nvim_win_get_cursor, self.winid)
    self:modifiable(function()
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
        vim.api.nvim_buf_clear_namespace(self.bufnr, -1, 0, -1)

        Renderer.super.draw(self, self, self._.opts)
    end)
    if c_ok then
        pcall(vim.api.nvim_win_set_cursor, self.winid, c)
    end
end

---@private
---
---@param fn function
function Renderer:modifiable(fn)
    local bufnr = self.bufnr
    if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
        return
    end

    local modi = vim.api.nvim_buf_get_option(bufnr, "modifiable")
    if not modi then
        vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    end
    fn()
    if not modi then
        vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    end
end

function Renderer:map(mode, key, handler, opts) --
    if not self.bufnr then
        return
    end
    if type(key) == "number" then
        key = tostring(key)
    end

    if type(key) == "table" then
        for _, k in ipairs(key) do
            self:map(mode, k, handler, opts)
        end
    elseif type(key) == "string" then
        local options =
            vim.tbl_deep_extend("force", { buffer = self.bufnr, clearable = false }, opts or {})

        local clearable = options.clearable
        options.clearable = nil

        if clearable then
            self._.keymaps[key] = mode
        end
        vim.keymap.set(mode, key, handler, options)
        vim.keymap.set(mode, key, handler, options)
    end
end

function Renderer:unmap(mode, key) --
    pcall(vim.api.nvim_buf_del_keymap, self.bufnr, mode, key)
end

function Renderer:clear_keymaps()
    for key, mode in pairs(self._.keymaps) do
        self:unmap(mode, key)
    end

    self._.keymaps = {}
end

function Renderer:clear()
    Renderer.super.clear(self)

    self._.line_idx = 1
    self._.buttons = {}
    self:clear_keymaps()
    self:modifiable(function()
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
    end)
end

---@param val? integer Optional value to increment line index by
function Renderer:get_line_idx(val)
    local line_idx = self._.line_idx
    self._.line_idx = self._.line_idx + (val or 0)
    return line_idx
end

---@param line_idx? integer The line that the press happened
function Renderer:handle_press(line_idx)
    local function feedenter()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "n", true)
    end

    if not self.bufnr or not self.winid then
        feedenter()
    end
    if not line_idx and not vim.api.nvim_win_is_valid(self.winid) then
        return feedenter()
    end

    line_idx = line_idx or vim.api.nvim_win_get_cursor(self.winid)[1]

    if not self._.buttons[line_idx] then
        return feedenter()
    end

    local ok, err = pcall(function()
        self._.buttons[line_idx]:press()
    end)
    if not ok then
        log.error(err)
    end
end

---@param button lc.ui.Button
function Renderer:apply_button(button) --
    local line_idx = self._.line_idx

    for i = 1, #button:contents() do
        self._.buttons[line_idx + i - 1] = button
    end
end

---@param layout lc.ui.Renderer
function Renderer:set(layout)
    self._.items = layout._.items
end

---@param components lc.ui.Lines[]
---@param opts? lc.ui.opts
function Renderer:init(components, opts)
    Renderer.super.init(self, components or {}, opts or {})

    self._.line_idx = 1
    self._.buttons = {}
    self._.keymaps = {}
end

---@type fun(components?: table[], opts?: lc.ui.opts): lc.ui.Renderer
local LeetRenderer = Renderer

return LeetRenderer
