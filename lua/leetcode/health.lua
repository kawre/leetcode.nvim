-- `:checkhealth leetcode`

local M = {}

function M.check()
    local deps = require("leetcode.deps")

    vim.health.start("Neovim")
    if vim.fn.has("nvim-0.11.0") == 1 then
        vim.health.ok(("Neovim %s"):format(tostring(vim.version())))
    else
        vim.health.error("Neovim 0.11.0 or newer is needed", { "Update Neovim" })
    end

    vim.health.start("markup.nvim")
    local problem = deps.check()
    if problem then
        vim.health.error(problem)
    else
        vim.health.ok(
            ("markup.nvim %s, with its engine (%s or newer is needed)"):format(
                require("markup.config").version,
                deps.markup
            )
        )
    end

    vim.health.start("Optional")
    if pcall(require, "nvim-web-devicons") then
        vim.health.ok("nvim-web-devicons, for language icons")
    else
        vim.health.info("nvim-web-devicons is not installed: no language icons")
    end
end

return M
