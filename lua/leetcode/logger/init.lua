local config = require("leetcode.config")

---@class lc.Logger
local Logger = {}

---@param msg string
---@param lvl? string
Logger.log = function(msg, lvl) require("notify")(config.name .. ": " .. msg, lvl or "info") end

---@param msg string
Logger.info = function(msg) Logger.log(msg) end

---@param msg string
Logger.warn = function(msg) Logger.log(msg, "warn") end

---@param msg string
Logger.debug = function(msg) Logger.log(msg, "debug") end

---@param msg table
Logger.inspect = function(msg) Logger.log(vim.inspect(msg)) end

---@param msg string
Logger.error = function(msg) Logger.log(msg, "error") end

return Logger
