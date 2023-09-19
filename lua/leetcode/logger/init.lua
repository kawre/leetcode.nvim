local config = require("leetcode.config")
local levels = vim.log.levels

---@class lc.Logger
local Logger = {}

---@param msg string
---@param lvl? integer
Logger.log = function(msg, lvl)
    if not config.user.logging then return end
    vim.notify(msg, lvl or levels.INFO, { title = config.name })
end

---@param msg string
Logger.info = function(msg) Logger.log(msg) end

---@param msg string
Logger.warn = function(msg) Logger.log(msg, levels.WARN) end

---@param msg table
Logger.inspect = function(msg) Logger.log(vim.inspect(msg)) end

---@param msg string
Logger.error = function(msg) Logger.log(msg, levels.ERROR) end

---@param msg string
Logger.debug = function(msg)
    if not config.debug then return end
    Logger.log(msg, levels.DEBUG)
end

return Logger
