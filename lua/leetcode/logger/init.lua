local config = require("leetcode.config")
local lvls = vim.log.levels

---@class leet.Logger
---@field trace fun(...)
---@field debug fun(...)
---@field info fun(...)
---@field warn fun(...)
---@field error fun(...)
---@field off fun(...)
local logger = {}

local function normalize(msg)
    if type(msg) == "string" then
        return msg
    else
        return vim.inspect(msg, { depth = 3 })
    end
end

---@private
---@param lvl number
---@param ... any
function logger.log(lvl, ...)
    if not config.debug and (lvl == lvls.DEBUG or lvl == lvls.TRACE) then
        return
    end

    local msg = table.concat(vim.tbl_map(normalize, { ... }), " ")
    vim.notify(msg, lvl, {
        title = config.name,
        on_open = function(win)
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
            vim.api.nvim_set_option_value("spell", false, { win = win })
        end,
    })
end

---@param err lc.err
logger.err = function(err)
    if not err or not err.msg then
        return logger.error("unknown error")
    end

    logger.error(err.msg)
end

return setmetatable(logger, {
    __index = function(_, key)
        return function(...)
            local lvl = lvls[key:upper()]
            if lvl then
                return logger.log(lvl, ...)
            else
                return logger.error("Invalid log level:", key)
            end
        end
    end,
})
