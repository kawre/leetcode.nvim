local log = require("leetcode.logger")

local utils = {}

function utils.set_buf_opts(bufnr, options)
    if not bufnr then return end

    for opt, value in pairs(options) do
        local ok, err = pcall(vim.api.nvim_set_option_value, opt, value, { buf = bufnr })
        if not ok then log.error(err) end
    end
end

function utils.set_win_opts(winid, options)
    if not winid then return end

    for opt, value in pairs(options) do
        local ok, err =
            pcall(vim.api.nvim_set_option_value, opt, value, { win = winid, scope = "local" })
        if not ok then log.error(err) end
    end
end

return utils
