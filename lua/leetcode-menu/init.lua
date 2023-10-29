local utils = require("leetcode-menu.utils")
local log = require("leetcode.logger")
local cookie = require("leetcode.cache.cookie")

---@class lc-menu
---@field layout lc-ui.Layout
---@field bufnr integer
---@field winid integer
---@field tabpage integer
---@field cursor lc-menu.cursor
---@field maps table
local menu = {} ---@diagnostic disable-line
menu.__index = menu

local function tbl_keys(t)
    local keys = vim.tbl_keys(t)
    if not keys then return end
    table.sort(keys)
    return keys
end

function menu:draw()
    self:clear_keymaps()
    self.layout:draw(self) ---@diagnostic disable-line
    self:apply_btn_keymaps()
end

function menu:clear_keymaps()
    for _, map in ipairs(self.maps) do
        vim.keymap.del(map.mode, map.lhs, { buffer = self.bufnr })
    end

    self.maps = {}
end

function menu:apply_btn_keymaps()
    local opts = { noremap = false, silent = true, buffer = self.bufnr, nowait = true }

    for _, btn in pairs(self.layout.buttons) do
        if not btn.sc then return end

        local mode = { "n" }
        vim.keymap.set(mode, btn.sc, btn.fn, opts)
        table.insert(self.maps, { mode = mode, lhs = btn.sc })
    end
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

---@param layout_name layouts
function menu:set_layout(layout_name)
    self:cursor_reset()

    local ok, layout = pcall(require, "leetcode-menu.layout." .. layout_name)
    if ok then
        self.layout = layout
        self:draw()
    end

    return self
end

---@private
function menu:keymaps()
    local press_fn = function()
        local row = vim.api.nvim_win_get_cursor(self.winid)[1]
        self.layout:handle_press(row)
    end

    vim.keymap.set("n", "<cr>", press_fn, { buffer = self.bufnr })
    vim.keymap.set("n", "<Tab>", press_fn, { buffer = self.bufnr })
end

function menu:handle_mount()
    if cookie.get() then
        self:set_layout("loading")

        local auth_api = require("leetcode.api.auth")
        auth_api._user(function(auth, err)
            if err then
                log.warn(err.msg)
                self:set_layout("signin")
                return
            end

            local logged_in = auth.is_signed_in
            local layout = logged_in and "menu" or "signin"
            self:set_layout(layout)
        end)
    else
        self:set_layout("signin")
    end

    log.debug(self)
    return self:mount()
end

function menu:mount()
    self:keymaps()
    self:autocmds()
    self:draw()
end

function menu:init()
    self = setmetatable({
        bufnr = vim.api.nvim_get_current_buf(),
        winid = vim.api.nvim_get_current_win(),
        cursor = {
            idx = 1,
        },
        maps = {},
    }, self)

    vim.api.nvim_buf_set_name(self.bufnr, "")
    pcall(vim.diagnostic.disable, self.bufnr)
    utils.set_buf_opts(self.bufnr, {
        modifiable = false,
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
    })
    utils.set_win_opts(self.winid, {
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

    _Lc_Menu = self
    return self:handle_mount()
end

return menu
