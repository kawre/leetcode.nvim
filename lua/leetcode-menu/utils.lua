local log = require("leetcode.logger")

local utils = {}

function utils.apply_opt_local(options)
    local bufnr = vim.api.nvim_get_current_buf()
    log.debug("applying `opt_local` to bufnr: " .. bufnr)

    for key, value in pairs(options) do
        vim.api.nvim_set_option_value(key, value, { scope = "local" })
    end
end

return utils
