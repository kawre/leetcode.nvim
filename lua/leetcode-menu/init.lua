local log = require("leetcode.logger")
local Cookie = require("leetcode.cache.cookie")
local utils = require("leetcode.utils")
local Layout = require("leetcode-ui.layout")

---@class lc-menu : lc-ui.Layout
---@field tabpage integer
---@field cursor lc-menu.cursor
---@field maps table
local Menu = Layout:extend("LeetMenu")

local function tbl_keys(t)
    local keys = vim.tbl_keys(t)
    if not keys then return end
    table.sort(keys)
    return keys
end

function Menu:draw()
    self:clear_keymaps()
    Menu.super.draw(self)
    self:apply_btn_keymaps()
end

function Menu:clear_keymaps()
    for _, map in ipairs(self.maps) do
        vim.keymap.del(map.mode, map.lhs, { buffer = self._.opts.bufnr })
    end

    self.maps = {}
end

function Menu:apply_btn_keymaps()
    local opts = { noremap = false, silent = true, buffer = self._.opts.bufnr, nowait = true }

    for _, btn in pairs(self._.buttons) do
        local bopts = btn._.opts
        if not bopts.sc then return end

        local mode = { "n" }
        vim.keymap.set(mode, bopts.sc, bopts.on_press, opts)
        table.insert(self.maps, { mode = mode, lhs = bopts.sc })
    end
end

---@private
function Menu:autocmds()
    local group_id = vim.api.nvim_create_augroup("leetcode_menu", { clear = true })

    vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self._.opts.bufnr,
        callback = function() self:draw() end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group_id,
        buffer = self._.opts.bufnr,
        callback = function() self:cursor_move() end,
    })
end

function Menu:cursor_move()
    local curr = vim.api.nvim_win_get_cursor(self._.opts.winid)
    local prev = self.cursor.prev

    local keys = tbl_keys(self._.buttons)
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
    vim.api.nvim_win_set_cursor(self._.opts.winid, self.cursor.prev)
end

function Menu:cursor_reset()
    self.cursor.idx = 1
    self.cursor.prev = nil
end

---@param name layouts
function Menu:set(name)
    self:cursor_reset()

    local ok, layout = pcall(require, "leetcode-menu.layout." .. name)
    if ok then
        Menu.super.set(self, layout)
        self:draw()
    else
        log.error(layout)
    end

    return self
end

---@private
function Menu:keymaps()
    local press_fn = function()
        local row = vim.api.nvim_win_get_cursor(self._.opts.winid)[1]
        self:handle_press(row)
    end

    vim.keymap.set("n", "<cr>", press_fn, { buffer = self._.opts.bufnr })
    vim.keymap.set("n", "<Tab>", press_fn, { buffer = self._.opts.bufnr })
end

function Menu:handle_mount()
    if Cookie.get() then
        self:set("loading")

        local auth_api = require("leetcode.api.auth")
        auth_api.user(function(_, err)
            if err then
                self:set("signin")
                return log.err(err)
            else
                self:set("menu")
            end
        end)
    else
        self:set("signin")
    end

    return self:mount()
end

function Menu:mount()
    self:keymaps()
    self:autocmds()
    self:draw()
end

function Menu:init()
    Menu.super.init(self, {}, {
        bufnr = vim.api.nvim_get_current_buf(),
        winid = vim.api.nvim_get_current_win(),
    })

    self.cursor = {
        idx = 1,
        prev = nil,
    }
    self.maps = {}

    vim.api.nvim_buf_set_name(self._.opts.bufnr, "")
    pcall(vim.diagnostic.disable, self._.opts.bufnr)

    local utils = require("leetcode-menu.utils")
    utils.set_buf_opts(self._.opts.bufnr, {
        modifiable = false,
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
    })
    utils.set_win_opts(self._.opts.winid, {
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

---@type fun(): lc-menu
local LeetMenu = Menu

return LeetMenu
