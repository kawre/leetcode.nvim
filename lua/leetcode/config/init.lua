local template = require("leetcode.config.template")
local P = require("plenary.path")

_Lc_state = {
    menu = nil, ---@type lc.ui.Menu
    questions = {}, ---@type lc.ui.Question[]
}

local lazy_plugs = {}

---@class lc.Config
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
    theme = {}, ---@type lc.highlights

    translator = false,

    langs = require("leetcode.config.langs"),
    icons = require("leetcode.config.icons"),
    sessions = require("leetcode.config.sessions"),
    stats = require("leetcode.config.stats"),
    imports = require("leetcode.config.imports"),
    hooks = require("leetcode.config.hooks"),

    ---@type lc.UserStatus
    auth = {}, ---@diagnostic disable-line
}

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.UserConfig Configurations to be merged.
function config.apply(cfg)
    config.user = vim.tbl_deep_extend("force", config.default, cfg or {})
    config.load_plugins()
end

function config.setup()
    config.validate()

    -- deprecate `directory` config
    if config.user.directory then
        local log = require("leetcode.logger")
        log.warn("leetcode.nvim config: `directory` is deprecated. Use `storage.home` instead.")
        config.user.storage.home = config.user.directory
    end

    config.user.storage = vim.tbl_map(vim.fn.expand, config.user.storage)

    config.debug = config.user.debug or false ---@diagnostic disable-line
    config.lang = config.user.lang

    config.storage.home = P:new(config.user.storage.home) ---@diagnostic disable-line
    config.storage.home:mkdir()

    config.storage.cache = P:new(config.user.storage.cache) ---@diagnostic disable-line
    config.storage.cache:mkdir()

    for _, plug_load_fn in ipairs(lazy_plugs) do
        plug_load_fn()
    end
end

function config.validate()
    local utils = require("leetcode.utils")

    assert(vim.fn.has("nvim-0.9.0") == 1, "Neovim >= 0.9.0 required")

    if not utils.get_lang(config.lang) then
        ---@type lc.lang[]
        local lang_slugs = vim.tbl_map(function(lang)
            return lang.slug
        end, config.langs)

        local matches = {}
        for _, slug in ipairs(lang_slugs) do
            local percent = slug:match(config.lang) or config.lang:match(slug)
            if percent then
                table.insert(matches, slug)
            end
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
        table.insert(plugins, "cn")
    end

    for plugin, enabled in pairs(config.user.plugins) do
        if enabled then
            table.insert(plugins, plugin)
        end
    end

    for _, plugin in ipairs(plugins) do
        local ok, plug = pcall(require, "leetcode-plugins." .. plugin)

        if ok then
            if not (plug.opts or {}).lazy then
                plug.load()
            else
                table.insert(lazy_plugs, plug.load)
            end
        else
            table.insert(lazy_plugs, function()
                local log = require("leetcode.logger")
                log.error(plug)
            end)
        end
    end
end

return config
