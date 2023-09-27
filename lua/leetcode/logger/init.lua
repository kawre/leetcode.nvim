local config = require("leetcode.config")
local levels = vim.log.levels

---@class lc.Logger
local logger = {}

---@alias msg string | number

---@param msg msg
---@param lvl? integer
logger.log = function(msg, lvl)
    if not config.user.logging then return end

    if type(msg) == "number" then msg = tostring(msg) end
    vim.notify(msg, lvl or levels.INFO, { title = config.name })
end

---@param msg msg
logger.info = function(msg) logger.log(msg) end

---@param msg msg
logger.warn = function(msg) logger.log(msg, levels.WARN) end

---@param msg table
logger.inspect = function(msg) logger.log(vim.inspect(msg)) end

---@param msg msg
logger.error = function(msg) logger.log(msg, levels.ERROR) end

---@param msg msg
logger.debug = function(msg)
    if not config.debug then return end
    logger.log(msg, levels.DEBUG)
end

return logger
