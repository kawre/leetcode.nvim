local log = require("leetcode.logger")
local cookie = require("leetcode.cache.cookie")
local config = require("leetcode.config")
local utils = require("leetcode-ui.utils")
local Renderer = require("leetcode-ui.renderer")
local api = vim.api

---@class lc.ui.Menu : lc.ui.Renderer
---@field cursor lc-menu.cursor
---@field maps table
local Menu = Renderer:extend("LeetMenu")

local function tbl_keys(t)
    local keys = vim.tbl_keys(t)
    if vim.tbl_isempty(keys) then
        return
    end
    table.sort(keys)
    return keys
end

function Menu:draw()
    Menu.super.draw(self, self)
    return self
end

---@private
function Menu:autocmds()
    local group_id = api.nvim_create_augroup("leetcode_menu", { clear = true })

    api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self.bufnr,
        callback = function()
            self:draw()
        end,
    })

    api.nvim_create_autocmd("CursorMoved", {
        group = group_id,
        buffer = self.bufnr,
        callback = function()
            self:cursor_move()
        end,
    })

    api.nvim_create_autocmd("QuitPre", {
        group = group_id,
        buffer = self.bufnr,
        callback = function()
            self.winid = nil
            self.bufnr = nil
            self:clear_keymaps()
        end,
    })
end

function Menu:cursor_move()
    if not (self.winid and api.nvim_win_is_valid(self.winid)) then
        return
    end

    local curr = api.nvim_win_get_cursor(self.winid)
    local prev = self.cursor.prev

    local keys = tbl_keys(self._.buttons)
    if not keys then
        return
    end

    local function find_nearest(l, r)
        while l < r do
            local m = math.floor((l + r) / 2)

            if keys[m] < curr[1] then
                l = m + 1
            else
                r = m
            end
        end

        return math.max(r, 1)
    end

    if prev then
        local next_idx = self.cursor.idx

        if curr[1] < prev[1] then
            next_idx = find_nearest(1, self.cursor.idx - 1)
        elseif curr[1] > prev[1] then
            next_idx = find_nearest(self.cursor.idx + 1, #keys)
        end

        self.cursor.idx = next_idx
    end

    local row = keys[self.cursor.idx]
    local col = #vim.fn.getline(row):match("^%s*")

    self.cursor.prev = { row, col }
    api.nvim_win_set_cursor(self.winid, self.cursor.prev)
end

function Menu:cursor_reset()
    self.cursor.idx = 1
    self.cursor.prev = nil
end

---@param name lc-menu.page
function Menu:set_page(name)
    self:cursor_reset()

    local ok, page = pcall(require, "leetcode-ui.group.page." .. name)
    if ok then
        self:replace({ page })
    else
        log.error(page)
    end

    return self:draw()
end

function Menu:apply_options()
    api.nvim_buf_set_name(self.bufnr, "")

    utils.set_buf_opts(self.bufnr, {
        modifiable = false,
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = config.name,
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
end

function Menu:unmount()
    if vim.v.dying ~= 0 then
        return
    end

    require("leetcode.command").q_close_all()

    vim.schedule(function()
        if self.winid and vim.api.nvim_win_is_valid(self.winid) then
            vim.api.nvim_win_close(self.winid, true)
        end

        if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
            vim.api.nvim_buf_delete(self.bufnr, { force = true })
        end
    end)
end

function Menu:remount()
    if self.winid and api.nvim_win_is_valid(self.winid) then
        api.nvim_win_close(self.winid, true)
    end
    if self.bufnr and api.nvim_buf_is_valid(self.bufnr) then
        api.nvim_buf_delete(self.bufnr, { force = true })
    end

    vim.cmd("$tabnew")
    self.bufnr = api.nvim_get_current_buf()
    self.winid = api.nvim_get_current_win()

    self:_mount()
end

function Menu:mount()
    if cookie.get() then
        self:set_page("loading")

        local auth_api = require("leetcode.api.auth")
        auth_api.user(function(_, err)
            if err then
                self:set_page("signin")
                log.err(err)
            else
                local cmd = require("leetcode.command")
                cmd.start_user_session()
            end
        end)
    else
        self:set_page("signin")
    end

    self:_mount()

    return self
end

function Menu:_mount()
    self:apply_options()
    self:autocmds()
    self:draw()
end

function Menu:init()
    Menu.super.init(self, {}, {
        position = "center",
    })

    self.cursor = {
        idx = 1,
        prev = nil,
    }
    self.maps = {}

    self.bufnr = api.nvim_get_current_buf()
    self.winid = api.nvim_get_current_win()

    _Lc_state.menu = self
end

---@type fun(): lc.ui.Menu
local LeetMenu = Menu

return LeetMenu
