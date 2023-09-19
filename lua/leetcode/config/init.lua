local template = require("leetcode.config.template")

---@class lc.Settings
local Config = {
  name = "leetcode.nvim",
  debug = true,
}

---Default configurations.
---
---@type lc.Config
Config.default = template

---User configurations.
---
---@type lc.Config
Config.user = Config.default

---@type lc.UserStatus|nil
Config.auth = nil

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.Config Configurations to be merged.
function Config.apply(cfg)
  Config.user = vim.tbl_deep_extend("force", template, cfg)

  local ok, notify = pcall(require, "notify")
  if ok then vim.notify = notify end
end

---Merge configurations into default configurations and set it as user configurations.
---
---@param status lc.UserStatus | nil
function Config.authenticate(status) Config.auth = status end

return Config
