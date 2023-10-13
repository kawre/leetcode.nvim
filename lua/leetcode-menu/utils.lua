local utils = {}

function utils.apply_opt_local(options)
    for key, value in pairs(options) do
        vim.api.nvim_set_option_value(key, value, { scope = "local" })
    end
end

return utils
