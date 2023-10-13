local n_ok, notify = pcall(require, "notify")
if n_ok then vim.notify = notify end

local config = require("leetcode.config")
local lvls = vim.log.levels

---@class lc.Logger
local logger = {}

---@alias msg string | number | boolean | table | nil

local function normalize(msg) return type(msg) == "string" and msg or vim.inspect(msg) end

---@param msg msg
---@param lvl? integer
---@return any
logger.log = function(msg, lvl)
    if not config.user.logging then return end
    vim.notify(normalize(msg), lvl or lvls.INFO, { title = config.name })

    return msg
end

---@param msg msg
---@return any
logger.info = function(msg) return logger.log(msg) end

---@param msg msg
---@return any
logger.warn = function(msg) return logger.log(msg, lvls.WARN) end

---@param msg msg
---@return any
logger.error = function(msg) return logger.log(msg, lvls.ERROR) end

---@param msg msg
---@return any
logger.debug = function(msg)
    if not config.debug then return end
    logger.log(debug.traceback(normalize(msg)), lvls.DEBUG)

    return msg
end

return logger
