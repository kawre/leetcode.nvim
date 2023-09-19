local logger = require("leetcode.logger")
local components = require("leetcode.ui.components")
local gql = require("leetcode.graphql")

---@class lc.UI
local Ui = {}

---@param items table
---@param prompt? string
---@param fn? fun(table)
---@param callback fun(table)
function Ui.pick_one(items, prompt, fn, callback)
    vim.ui.select(items, {
        prompt = prompt or "",
        format_item = fn or function(item) return item end,
        telescope = require("telescope.themes").get_dropdown(),
    }, callback)
end

function Ui.input(opts, callback) vim.ui.input(opts, callback) end

---@param problem lc.Problem
function Ui.create_leetcode_win(problem)
    local start_win = vim.api.nvim_get_current_win()

    local Split = require("nui.split")
    local split = Split({
        relative = "win",
        position = "left",
        size = "30%",
    })
    split:mount()

    local title = gql.question.title(problem.title_slug)
    local content = gql.question.content(problem.title_slug)

    local win = vim.api.nvim_get_current_win() -- We save our navigation window handle...
    local buf = vim.api.nvim_get_current_buf() -- ...and it's buffer handle.

    vim.api.nvim_buf_set_name(buf, "LeetCode")

    vim.api.nvim_buf_set_option(buf, "filetype", "leetcode.nvim")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "buflisted", false)
    -- vim.api.nvim_buf_set_option(buf, "modifiable", true)

    vim.api.nvim_win_set_option(win, "wrap", true)
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "signcolumn", "no")

    vim.api.nvim_buf_set_keymap(buf, "n", "<esc>", "<cmd>hide<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>hide<CR>", { noremap = true })

    local line = require("nui.line")()
    line:append("")

    components.problem.link(problem.title_slug):render(buf, -1, 1)
    line:render(buf, -1, 2)

    components.problem.title(title):render(buf, -1, 3)
    components.problem.stats(title):render(buf, -1, 4)
    line:render(buf, -1, 5)

    components.problem.content(content):render(buf, -1, 6)
end

return Ui
