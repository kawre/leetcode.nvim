local component = require("leetcode-ui.component")
local log = require("leetcode.logger")
local utils = require("leetcode-menu.utils")
local config = require("leetcode.config")

local Text = require("nui.text")
local Line = require("nui.line")

---@class lc-menu
---@field layout lc-ui.Layout
---@field bufnr integer
---@field winid integer
---@field tabpage integer
local menu = {} ---@diagnostic disable-line
menu.__index = menu

---@type lc-menu
_LC_MENU = {} ---@diagnostic disable-line

function menu:clear() vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {}) end

function menu:redraw() self:draw() end

function menu:draw()
    self:clear()

    self.layout:draw(self)
end

---@private
function menu:autocmds()
    vim.api.nvim_create_autocmd("WinResized", {
        callback = function() self:draw() end,
    })
end

---@alias layouts
---| "menu"
---| "problems"
---| "statistics"
---| "cookie"
---| "cache"

---@param layout layouts
function menu:set_layout(layout)
    local ok, res = pcall(require, "leetcode-menu.theme." .. layout)
    if ok then self.layout = res end

    self:redraw()
end

---@private
function menu:keymaps()
    -- self.split:map("n", "<cr>", function()
    -- end)

    vim.keymap.set("n", "<cr>", function()
        local row = vim.api.nvim_win_get_cursor(self.winid)[1]
        self.layout:handle_press(row)
    end, {})
end

function menu:mount()
    self:keymaps()
    self:autocmds()

    self:draw()
end

function menu:init()
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.api.nvim_buf_set_name(bufnr, "")
    vim.api.nvim_set_current_tabpage(1)

    utils.apply_opt_local({
        bufhidden = "wipe",
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
        wrap = false,
        colorcolumn = "",
        foldlevel = 999,
        foldcolumn = "0",
        cursorcolumn = false,
        cursorline = false,
        number = false,
        relativenumber = false,
        list = false,
        spell = false,
        signcolumn = "no",
    })

    local logged_in = config.auth.is_signed_in
    local layout = logged_in and "menu" or "signin"
    local ok, l = pcall(require, "leetcode-menu.theme." .. layout)
    assert(ok)

    local obj = setmetatable({
        bufnr = bufnr,
        winid = winid,
        tabpage = tabpage,
        layout = l,
    }, self)

    _LC_MENU = obj
    return obj:mount()
end

return menu
