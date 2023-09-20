local config = require("leetcode.config")
local api = require("leetcode.api")
local dashboard = require("leetcode-ui")

local M = {}

---@param cfg? lc.Config
function M.setup(cfg)
    config.apply(cfg or {})

    vim.cmd([[highlight LcProblemEasy guifg=##00b8a3]])
    vim.cmd([[highlight LcProblemMedium guifg=#ffb800]])
    vim.cmd([[highlight LcProblemHard guifg=#ef4743]])

    vim.api.nvim_create_autocmd("VimEnter", {
        pattern = "*",
        nested = true,
        callback = function()
            if config.user.invoke_name == vim.fn.expand("%") then dashboard.setup() end
        end,
    })
end

return M
