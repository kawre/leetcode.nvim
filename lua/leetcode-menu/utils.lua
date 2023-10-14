local log = require("leetcode.logger")

local utils = {}

function utils.apply_opt_local(winid, options)
    if not winid then return end

    log.debug("applying `opt_local` to winid: " .. winid)
    for key, value in pairs(options) do
        pcall(vim.api.nvim_set_option_value, key, value, { win = winid, scope = "local" })
    end
end

return utils
