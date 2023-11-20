local template = require("leetcode.config.template")

---@type lc.Question[]
_Lc_questions = {}

---@type lc-menu
_Lc_Menu = {} ---@diagnostic disable-line

---@class lc.Settings
local config = {
    default = template,
    user = template,

    name = "leetcode.nvim",
    domain = "com",
    is_cn = false,
    debug = false,
    lang = "cpp",
    home = {}, ---@type Path
    version = "1.0.0",

    translator = false,

    langs = require("leetcode.config.langs"),
    icons = require("leetcode.config.icons"),

    ---@type lc.UserStatus
    auth = {}, ---@diagnostic disable-line
}

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.UserConfig Configurations to be merged.
function config.apply(cfg)
    config.user = vim.tbl_deep_extend("force", config.default, cfg)

    config.debug = config.user.debug or false ---@diagnostic disable-line
    config.lang = config.user.lang
end

function config.load_plugins()
    local plugins = {}

    if config.user.cn.enabled then
        config.translator = config.user.cn.translator
        table.insert(plugins, "cn")
    end

    for _, plugin in ipairs(plugins) do
        local ok, plug = pcall(require, "leetcode-plugins." .. plugin)
        if ok then plug.load() end
    end
end

return config
