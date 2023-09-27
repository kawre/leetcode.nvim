local config = require("leetcode.config")
local utils = require("leetcode.utils")
local cmd = require("leetcode.api.command")

---@class lc
local leetcode = {}

local function should_skip()
    if vim.fn.argc() ~= 1 then return true end

    local invoke, arg = config.user.arg, vim.fn.argv()[1]
    if arg ~= invoke then return true end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return true end

    return false
end

---@param cfg? lc.UserConfig
function leetcode.setup(cfg)
    config.apply(cfg or {})
    if should_skip() then return end

    vim.api.nvim_set_hl(0, "LeetCodeEasy", { fg = "#00b8a3" })
    vim.api.nvim_set_hl(0, "LeetCodeMedium", { fg = "#ffb800" })
    vim.api.nvim_set_hl(0, "LeetCodeHard", { fg = "#ef4743" })
    vim.api.nvim_set_hl(0, "LeetCodePTag", { link = "Comment" })
    vim.api.nvim_set_hl(0, "LeetCodeEmTag", { italic = true })
    vim.api.nvim_set_hl(0, "LeetCodeStrongTag", { bold = true })
    vim.api.nvim_set_hl(0, "LeetCodeCodeTag", { link = "DiagnosticHint" })
    vim.api.nvim_set_hl(0, "LeetCodeSupTag", { link = "MatchParen" })
    vim.api.nvim_set_hl(0, "LeetCodePreTag", { link = "@text" })

    vim.api.nvim_set_hl(0, "LeetCodeIndent", { link = "Comment" })

    local group_id = vim.api.nvim_create_augroup("leetcode_start", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = group_id,
        pattern = "*",
        nested = true,
        callback = function(_) cmd.start() end,
    })

    utils.map("n", "<leader>lc", utils.cmd("console"))
    utils.map("n", "<leader>lm", utils.cmd("menu"))
    utils.map("n", "<leader>lq", utils.cmd("questions"))

    -- vim.api.nvim_create_user_command("LcMenu", function() vim.api.nvim_set_current_tabpage(1) end, {
    --     bang = true,
    --     desc = "Opens LeetCode Menu",
    --     nargs = 0,
    --     bar = true,
    -- })
    --
    -- vim.api.nvim_create_user_command(
    --     "LcQuestion",
    --     function() vim.api.nvim_set_current_tabpage() end,
    --     {
    --         bang = true,
    --         desc = "Opens last openned LeetCode question",
    --         nargs = 0,
    --         bar = true,
    --     }
    -- )
end

return leetcode
