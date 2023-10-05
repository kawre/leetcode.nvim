local config = require("leetcode.config")
local levels = vim.log.levels

---@class lc.Logger
local logger = {}

---@alias msg string | number | boolean | table | nil

---@param msg msg
---@param lvl? integer
logger.log = function(msg, lvl)
    if not config.user.logging then return end
    msg = msg or "nil"

    local mtype = type(msg)
    if mtype == "number" or mtype == "boolean" then msg = tostring(msg) end
    if mtype == "table" or mtype == "userdata" then msg = vim.inspect(msg) end
    vim.notify(msg, lvl or levels.INFO, { title = config.name })
end

---@param msg msg
logger.info = function(msg) logger.log(msg) end

---@param msg msg
logger.warn = function(msg) logger.log(msg, levels.WARN) end

---@param msg msg
logger.error = function(msg) logger.log(msg, levels.ERROR) end

---@param msg msg
logger.debug = function(msg)
    if not config.debug then return end
    logger.log(msg, levels.DEBUG)
end

return logger
