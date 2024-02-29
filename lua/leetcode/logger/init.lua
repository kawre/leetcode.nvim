local n_ok, notify = pcall(require, "notify")
if n_ok then
    vim.notify = notify
end

local config = require("leetcode.config")
local t = require("leetcode.translator")
local lvls = vim.log.levels

---@class lc.Logger
local logger = {}

local function normalize(msg)
    return type(msg) == "string" and t(msg) or vim.inspect(msg)
end

-- ---@private
-- ---@param msg any
-- ---@param lvl? integer
-- ---@return any
-- logger.log = vim.schedule_wrap(function(msg, lvl)
-- end)

function logger.log(msg, lvl)
    if not config.user.logging then
        return
    end

    local title = config.name
    lvl = lvl or lvls.INFO
    msg = normalize(msg)

    if lvl == lvls.DEBUG then
        msg = debug.traceback(msg .. "\n")
    end

    vim.notify(msg, lvl, { title = title })
end

---@param msg any
logger.info = function(msg)
    logger.log(msg)
end

---@param msg any
logger.warn = function(msg)
    logger.log(msg, lvls.WARN)
end

---@param msg any
logger.error = function(msg)
    logger.log(msg, lvls.ERROR)
    logger.debug(msg)
end

---@param err lc.err
logger.err = function(err)
    if not err then
        return logger.error("error")
    end

    local msg = err.msg or ""
    local lvl = err.lvl or lvls.ERROR

    logger.log(msg, lvl)
end

---@param msg any
---@param show? boolean
---@return any
logger.debug = function(msg, show)
    if not config.debug then
        return msg
    end

    local lvl = (show == nil or not show) and lvls.DEBUG or lvls.ERROR
    logger.log(msg, lvl)

    return msg
end

return logger
