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

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.Config Configurations to be merged.
function Config.apply(cfg) Config.user = vim.tbl_deep_extend("force", template, cfg) end

return Config
