local utils = {}

function utils.apply_opt_local(options)
    for key, value in pairs(options) do
        vim.opt_local[key] = value
    end
end

return utils
