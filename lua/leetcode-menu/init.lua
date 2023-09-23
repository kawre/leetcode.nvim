local component = require("leetcode-ui.component")
local log = require("leetcode.logger")

local Split = require("nui.split")
local Text = require("nui.text")
local Line = require("nui.line")

---@class lc-db.Dashboard
---@field split NuiSplit
---@field layout lc-ui.Layout
local dashboard = { split = {} } ---@diagnostic disable-line
dashboard.__index = dashboard

---@type table<bufnr, lc-db.Dashboard>
db = {}

function dashboard:clear() vim.api.nvim_buf_set_lines(self.split.bufnr, 0, -1, false, {}) end

function dashboard:redraw() self:draw() end

function dashboard:draw()
    self:clear()

    self.layout:draw(self.split)
end

---@private
function dashboard:autocmds()
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
function dashboard:set_layout(layout)
    local ok, res = pcall(require, "leetcode-menu.theme." .. layout)
    if ok then self.layout = res end

    self:redraw()
end

---@private
function dashboard:keymaps()
    self.split:map("n", "<cr>", function()
        local row = vim.api.nvim_win_get_cursor(self.split.winid)[1]
        self.layout:handle_press(row)
    end)
end

function dashboard:mount()
    self.split:mount()
    vim.cmd("bd#")

    self:keymaps()
    self:autocmds()

    self:draw()
end

function dashboard:init()
    local split = Split({
        relative = "win",
        -- size = "100%",
        enter = true,
        name = "LeetCode",
        focusable = true,
        buf_options = {
            modifiable = true,
            readonly = false,
            filetype = "leetcode.nvim",
            swapfile = false,
            buftype = "nofile",
            buflisted = true,
        },
        win_options = {
            foldcolumn = "1",
            wrap = false,
            number = false,
            signcolumn = "no",
            cursorline = false,
        },
    })
    vim.api.nvim_buf_set_name(split.bufnr, "LeetCode")

    local menu = require("leetcode-menu.theme.menu")
    local obj = setmetatable({
        split = split,
        layout = menu,
    }, self)
    db[split.bufnr] = obj

    return obj
end

return dashboard
