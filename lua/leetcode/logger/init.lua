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

---@param msg any
---@param lvl? integer
---@param schedule? boolean
function logger.log(msg, lvl, schedule)
    if not config.user.logging then
        return
    end

    local title = config.name
    lvl = lvl or lvls.INFO
    msg = normalize(msg)

    if lvl == lvls.DEBUG then
        msg = debug.traceback(msg .. "\n")
    end

    local function notify_send()
        vim.notify(msg, lvl, { title = title })
    end

    if schedule then
        vim.schedule(notify_send)
    else
        notify_send()
    end
end

---@param msg any
---@param schedule? boolean
logger.info = function(msg, schedule)
    logger.log(msg, nil, schedule)
end

---@param msg any
---@param schedule? boolean
logger.warn = function(msg, schedule)
    logger.log(msg, lvls.WARN, schedule)
end

---@param msg any
---@param schedule? boolean
logger.error = function(msg, schedule)
    logger.log(msg, lvls.ERROR, schedule)
    logger.debug(msg)
end

---@param err lc.err
---@param schedule? boolean
logger.err = function(err, schedule)
    if not err then
        return logger.error("error")
    end

    local msg = err.msg or ""
    local lvl = err.lvl or lvls.ERROR

    logger.log(msg, lvl, schedule)
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
