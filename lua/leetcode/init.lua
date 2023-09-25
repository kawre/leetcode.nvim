local config = require("leetcode.config")
local dashboard = require("leetcode-menu")
local utils = require("leetcode.utils")
local log = require("leetcode.logger")
local cmd = require("leetcode.api.command")
local api = require("leetcode.api")
local cache = require("leetcode.cache")

local leetcode = {}

---@param cfg? lc.UserConfig
function leetcode.setup(cfg)
    config.apply(cfg or {})

    vim.api.nvim_set_hl(0, "LcProblemEasy", { fg = "#00b8a3" })
    vim.api.nvim_set_hl(0, "LcProblemMedium", { fg = "#ffb800" })
    vim.api.nvim_set_hl(0, "LcProblemHard", { fg = "#ef4743" })
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
