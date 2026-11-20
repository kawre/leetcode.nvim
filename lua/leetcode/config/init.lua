local template = require("leetcode.config.template")

local lazy_plugs = {}

---@class leet.config
local config = {
	default = template,
	user = template,

	name = "leetcode.nvim",
	domain = "com",
	is_cn = false,
	debug = false,
	lang = "cpp",
	version = "1.0.1",
	storage = {}, ---@type { home: string, cache: string } absolute paths
	theme = {}, ---@type lc.highlights
	plugins = {},

	translator = false,

	langs = require("leetcode.config.langs"),
	icons = require("leetcode.config.icons"),
	imports = require("leetcode.config.imports"),
	hooks = require("leetcode.config.hooks"),

	---@type lc.UserStatus
	auth = {}, ---@diagnostic disable-line
}

---Merge configurations into default configurations and set it as user configurations.
---
---@param cfg lc.UserConfig Configurations to be merged.
--- The language of the interface: `ui.locale` when set, or Chinese on
--- leetcode.cn with its translator on.
---@return "en"|"zh"
function config.locale()
	local ui = config.user and config.user.ui
	if ui and ui.locale then
		return ui.locale
	end
	return config.translator and "zh" or "en"
end

function config.apply(cfg)
	config.user = vim.tbl_deep_extend("force", config.default, cfg or {})
	config.load_plugins()
end

function config.setup()
	config.validate()

	Markup.animate.enabled = config.user.ui.animations

	-- deprecate `directory` config
	if config.user.directory then
		local log = require("leetcode.logger")
		log.warn("leetcode.nvim config: `directory` is deprecated. Use `storage.home` instead.")
		config.user.storage.home = config.user.directory
	end

	config.user.storage = vim.tbl_map(vim.fn.expand, config.user.storage)

	config.debug = config.user.debug or false ---@diagnostic disable-line
	config.lang = config.user.lang

	for _, name in ipairs({ "home", "cache" }) do
		local dir = vim.fs.abspath(config.user.storage[name])
		vim.fn.mkdir(dir, "p")
		config.storage[name] = dir
	end

	for _, plug_load_fn in ipairs(lazy_plugs) do
		plug_load_fn()
	end
end

function config.validate()
	local utils = require("leetcode.util")

	assert(vim.fn.has("nvim-0.11.0") == 1, "Neovim >= 0.11.0 required")

	local locale = config.user.ui and config.user.ui.locale
	if locale ~= nil and locale ~= "en" and locale ~= "zh" then
		error(("Unsupported ui.locale: %s, expected \"en\" or \"zh\""):format(vim.inspect(locale)))
	end

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
	config.plugins = {}
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
			config.plugins[plugin] = true
		else
			table.insert(lazy_plugs, function()
				local log = require("leetcode.logger")
				log.error(plug)
			end)
		end
	end
end

return config
