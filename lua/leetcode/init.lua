local config = require("leetcode.config")
local api = require("leetcode.api")
local dashboard = require("leetcode-menu")
local utils = require("leetcode.utils")

local M = {}

---@param cfg? lc.Config
function M.setup(cfg)
    config.apply(cfg or {})

    vim.api.nvim_set_hl(0, "LcProblemEasy", { fg = "#00b8a3" })
    vim.api.nvim_set_hl(0, "LcProblemMedium", { fg = "#ffb800" })
    vim.api.nvim_set_hl(0, "LcProblemHard", { fg = "#ef4743" })

    vim.api.nvim_create_autocmd("VimEnter", {
        pattern = "*",
        nested = true,
        callback = function()
            if config.user.invoke_name == vim.fn.expand("%") then dashboard:init():mount() end
        end,
    })

    ---@param fn string
    local function cmd(fn)
        return string.format("<cmd>lua require('leetcode.api.command').%s()<cr>", fn)
    end

    utils.map("n", "<leader>lc", cmd("console"))
    -- vim.keymap.set("n", '<leader>lc', rhs, opts)
end

return M
