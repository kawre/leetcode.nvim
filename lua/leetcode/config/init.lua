local template = require("leetcode.config.template")
local path = require("plenary.path")

-- local cache = require("leetcode.cache")

---@class lc.Settings
local config = {
    default = template, ---@type lc.UserConfig Default User configuration
    user = template, ---@type lc.UserConfig User configuration

    name = "leetcode.nvim",
    domain = "https://leetcode.com",
    debug = true,
    notify = false,
    lang = "cpp",
}

---@class lc.UserAuth
---@field name string
---@field is_signed_in boolean
---@field is_premium boolean
---@field id integer
config.auth = {}

config.default = template ---@type lc.UserConfig Default User configuration
config.user = template ---@type lc.UserConfig User configuration

-- config.cache = {}

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.UserConfig Configurations to be merged.
function config.apply(cfg)
    config.user = vim.tbl_deep_extend("force", config.default, cfg)

    local ok, notify = pcall(require, "notify")
    if ok then
        vim.notify = notify
        config.notify = true
    end

    config.domain = "https://leetcode." .. config.user.domain
    config.lang = config.user.lang

    path:new(config.user.directory):mkdir()
end

return config
