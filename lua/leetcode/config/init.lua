local template = require("leetcode.config.template")

---@class lc.Settings
local config = {
    default = template,
    user = template,

    name = "leetcode.nvim",
    domain = "https://leetcode.com",
    debug = false,
    lang = "cpp",
    toggle_console_on_run = false,
    toggle_console_on_submit = false,
    home = {}, ---@type Path
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
    config.toggle_console_on_run = config.user.toggle_console_on_run or false
    config.toggle_console_on_submit = config.user.toggle_console_on_submit or false
    config.debug = config.user.debug or false

    config.debug = config.user.debug or false ---@diagnostic disable-line
    config.domain = "https://leetcode." .. config.user.domain
    config.lang = config.user.lang
end

return config
