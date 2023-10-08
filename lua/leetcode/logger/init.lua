local config = require("leetcode.config")
local levels = vim.log.levels

---@class lc.Logger
local logger = {}

---@alias msg string | number | boolean | table | nil

---@param msg msg
---@param lvl? integer
logger.log = function(msg, lvl)
    if not config.user.logging then return end
    msg = type(msg) == "string" and msg or vim.inspect(msg)
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
