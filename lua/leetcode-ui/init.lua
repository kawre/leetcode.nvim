local component = require("leetcode-ui.component")
local log = require("leetcode.logger")

local Split = require("nui.split")
local Text = require("nui.text")
local Line = require("nui.line")

local dashboard = {}

---@type NuiSplit
local split

line_idx = 1

---@type lc.db.Component[]
local state = {}

function dashboard.redraw() end

function dashboard.clear()
    vim.api.nvim_buf_set_lines(split.bufnr, 0, -1, false, {})
    line_idx = 1
end

function dashboard.draw()
    dashboard.clear()

    -- local menu = require("leetcode-ui.theme.menu")
    local problems = require("leetcode-ui.theme.problems")
    -- local menu = require("leetcode-ui.theme.menu")
    -- local menu = require("leetcode-ui.theme.menu")
    problems:draw(split)
end

function dashboard.setup()
    split = Split({
        relative = "win",
        size = "100%",
        enter = true,
        focusable = true,
        buf_options = {
            -- modifiable = false,
            readonly = false,
            filetype = "leetcode.nvim",
            swapfile = false,
            buftype = "nofile",
            buflisted = false,
        },
        win_options = {
            -- winblend = 10,
            -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            foldcolumn = "1",
            wrap = true,
            number = false,
            signcolumn = "no",
            cursorline = false,
        },
    })
    split:mount()

    dashboard.split = split

    vim.cmd("bd#")

    vim.api.nvim_create_autocmd("WinResized", {
        -- group = group_id,
        callback = function() dashboard.draw() end,
    })

    dashboard.draw()
end

return dashboard
