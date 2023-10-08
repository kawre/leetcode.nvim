local template = require("leetcode.config.template")
local path = require("plenary.path")

---@class lc.Settings
local config = {
    default = template, ---@type lc.UserConfig Default User configuration
    user = template, ---@type lc.UserConfig User configuration

    name = "leetcode.nvim",
    domain = "https://leetcode.com",
    debug = true,
    lang = "cpp",
}

---@class lc.UserAuth
---@field name string
---@field is_signed_in boolean
---@field is_premium boolean
---@field id integer
config.auth = {}

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.UserConfig Configurations to be merged.
function config.apply(cfg)
    config.user = vim.tbl_deep_extend("force", config.default, cfg)
    config.domain = "https://leetcode." .. config.user.domain
    config.lang = config.user.lang
    config.directory = config.user.directory

    config.file = path:new(config.directory)
    config.file:mkdir()
end

return config
