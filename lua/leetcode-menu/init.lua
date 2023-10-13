local utils = require("leetcode-menu.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc-menu
---@field layout lc-ui.Layout
---@field bufnr integer
---@field winid integer
---@field tabpage integer
---@field cursor lc-menu.cursor
local menu = {} ---@diagnostic disable-line
menu.__index = menu

---@type table<integer, lc.Question>
_Lc_questions = {}

---@type integer
_Lc_curr_question = 0

---@type lc-menu
_Lc_Menu = {} ---@diagnostic disable-line
_Lc_MenuTabPage = 0

local function tbl_keys(t)
    local keys = vim.tbl_keys(t)
    if not keys then return end
    table.sort(keys)
    return keys
end

function menu:draw()
    self.layout:draw({ bufnr = self.bufnr, winid = self.winid }) ---@diagnostic disable-line
end

---@private
function menu:autocmds()
    local group_id = vim.api.nvim_create_augroup("leetcode_menu", { clear = true })

    vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self.bufnr,
        callback = function() self:draw() end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group_id,
        buffer = self.bufnr,
        callback = function() self:cursor_move() end,
    })
end

function menu:cursor_move()
    local curr = vim.api.nvim_win_get_cursor(self.winid)
    local prev = self.cursor.prev

    local keys = tbl_keys(self.layout.buttons)
    if not keys then return end

    if prev then
        if curr[1] > prev[1] then
            self.cursor.idx = math.min(self.cursor.idx + 1, #keys)
        elseif curr[1] < prev[1] then
            self.cursor.idx = math.max(self.cursor.idx - 1, 1)
        end
    end

    local row = keys[self.cursor.idx]
    local col = #vim.fn.getline(row):match("^%s*")

    self.cursor.prev = { row, col }
    vim.api.nvim_win_set_cursor(self.winid, self.cursor.prev)
end

function menu:cursor_reset()
    self.cursor.idx = 1
    self.cursor.prev = nil
end

---@param layout layouts
function menu:set_layout(layout)
    self:cursor_reset()

    local ok, res = pcall(require, "leetcode-menu.layout." .. layout)
    if ok then self.layout = res end

    self:draw()
end

---@private
function menu:keymaps()
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
    _Lc_MenuTabPage = tabpage

    utils.apply_opt_local({
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
        modifiable = false,
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

    local ok, loading = pcall(require, "leetcode-menu.layout.loading")
    assert(ok)

    local obj = setmetatable({
        bufnr = bufnr,
        winid = winid,
        tabpage = tabpage,
        layout = loading,
        cursor = {
            idx = 1,
            prev = nil,
        },
    }, self)

    local cookie = require("leetcode.cache.cookie")
    if cookie.get() then
        local auth_api = require("leetcode.api.auth")
        auth_api._user(function(auth, err)
            if err then
                log.warn(err.msg)
                obj:set_layout("signin")
                return
            end

            local logged_in = auth.is_signed_in
            local layout = logged_in and "menu" or "signin"
            obj:set_layout(layout)
        end)
    else
        obj:set_layout("signin")
    end

    _Lc_Menu = obj
    return obj:mount()
end

return menu
