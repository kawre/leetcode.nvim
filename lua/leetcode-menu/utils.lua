local log = require("leetcode.logger")

local utils = {}

function utils.set_buf_opts(bufnr, options)
    if not bufnr then return end

    log.debug("applying `opt_local` to bufnr: " .. bufnr)
    for key, value in pairs(options) do
        pcall(vim.api.nvim_set_option_value, key, value, { buf = bufnr })
    end
end

function utils.set_win_opts(winid, options)
    if not winid then return end

    log.debug("applying `opt_local` to winid: " .. winid)
    for key, value in pairs(options) do
        pcall(vim.api.nvim_set_option_value, key, value, { win = winid, scope = "local" })
    end
end

return utils
