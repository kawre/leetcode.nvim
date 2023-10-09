local template = require("leetcode.config.template")

---@class lc.Settings
local config = {
    default = template,
    user = template,

    name = "leetcode.nvim",
    domain = "https://leetcode.com",
    debug = false,
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
    local path = require("plenary.path")

    config.user = vim.tbl_deep_extend("force", config.default, cfg)

    config.debug = config.user.debug or false
    config.domain = "https://leetcode." .. config.user.domain
    config.lang = config.user.lang
    ---@type Path
    config.home = path:new(config.user.directory)
    config.home:mkdir()
end

return config
