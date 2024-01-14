local template = require("leetcode.config.template")
local P = require("plenary.path")

---@type lc.ui.Question[]
_Lc_questions = {}

---@type lc.ui.menu
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
    version = "1.0.1",
    storage = {}, ---@type table<string, Path>

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
    cfg.storage = cfg.storage or {}

    -- deprecate `directory` config
    if cfg.directory then
        local log = require("leetcode.logger")
        log.warn("Config: `directory` is deprecated. Use `storage.home` instead.")
        cfg.storage.home = cfg.directory
    end

    cfg.storage = vim.tbl_map(vim.fn.expand, cfg.storage)

    config.user = vim.tbl_deep_extend("force", config.default, cfg)

    config.debug = config.user.debug or false ---@diagnostic disable-line
    config.lang = config.user.lang

    config.validate()

    config.storage.home = P:new(config.user.storage.home) ---@diagnostic disable-line
    config.storage.home:mkdir()

    config.storage.cache = P:new(config.user.storage.cache) ---@diagnostic disable-line
    config.storage.cache:mkdir()
end

function config.validate()
    local utils = require("leetcode.utils")

    assert(vim.fn.has("nvim-0.9.0") == 1, "Neovim >= 0.9.0 required")

    if not utils.get_lang(config.lang) then --
        ---@type lc.lang[]
        local lang_slugs = vim.tbl_map(function(lang) return lang.slug end, config.langs)

        local matches = {}
        for _, slug in ipairs(lang_slugs) do
            local percent = slug:match(config.lang) or config.lang:match(slug)
            if percent then table.insert(matches, slug) end
        end

        if not vim.tbl_isempty(matches) then
            local log = require("leetcode.logger")
            log.warn("Did you mean: { " .. table.concat(matches, ", ") .. " }?")
        end

        error("Unsupported Language: " .. config.lang)
    end
end

function config.load_plugins()
    local plugins = {}

    if config.user.cn.enabled then
        config.translator = config.user.cn.translator
        table.insert(plugins, "cn")
    end

    for _, plugin in ipairs(plugins) do
        local ok, plug = pcall(require, "leetcode-plugins." .. plugin)
        if ok then
            plug.load()
        else
            local log = require("leetcode.logger")
            log.error(plug)
        end
    end
end

return config
