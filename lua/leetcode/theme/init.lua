local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
local log = require("leetcode.logger")
local config = require("leetcode.config")

---@class lc.Theme
local theme = {}

---@type table<string, string[]>
local dynamic_hls = {}

local highlights = {
    strong = "bold",
    b = "bold",

    em = "italic",
    i = "italic",

    u = "underline",

    a = "link",
    example = "example",
    constraints = "constraints",
    code = "code",
    input = "header",
    output = "header",
    explanation = "header",
    followup = "followup",

    -- pre = "",
    -- span = "",
    -- p = "",
    -- ul = "",
    -- ol = "",
    -- li = "",
    -- font = "",
    -- sup = "",
    -- sub = "",
    -- small = "",
    -- div = "",
}

function theme.load_devicons()
    ---@param l lc.language
    vim.tbl_map(function(l)
        local icon, color = devicons.get_icon_color(l.ft)

        if icon then l.icon = icon end
        if color then l.color = color end

        return l
    end, config.langs)
end

function theme.load()
    local defaults = require("leetcode.theme.default").get()

    for key, t in pairs(defaults) do
        key = "leetcode_" .. key
        vim.api.nvim_set_hl(0, key, t)
    end

    if devicons_ok then theme.load_devicons() end

    ---@param lang lc.language
    vim.tbl_map(function(lang)
        local name = "leetcode_lang_" .. lang.slug
        vim.api.nvim_set_hl(0, name, { fg = lang.color })
        lang.hl = name

        return lang
    end, config.langs)

    theme.load_dynamic(defaults)
end

function theme.load_dynamic(defaults)
    for name, tags in pairs(dynamic_hls) do
        theme.create_dynamic(name, tags, defaults)
    end
end

---@param tags string[]
function theme.get_dynamic(tags)
    if vim.tbl_isempty(tags) then return "leetcode_normal" end

    local name = "leetcode_dyn_" .. table.concat(tags, "_")
    if dynamic_hls[name] then return name end

    return theme.create_dynamic(name, tags)
end

---@param name string
---@param tags string[]
---@param defaults? table
function theme.create_dynamic(name, tags, defaults)
    defaults = defaults or require("leetcode.theme.default").get()

    local tbl = defaults["normal"]
    for _, tag in ipairs(tags) do
        local hl = highlights[tag]
        if hl then tbl = vim.tbl_extend("force", tbl, defaults[hl]) end
    end

    if tbl.italic or tbl.bold then
        if tbl.fg == defaults["normal"].fg then tbl.fg = defaults[""].fg end
    end

    if pcall(vim.api.nvim_set_hl, 0, name, tbl) then
        dynamic_hls[name] = tags
        return name
    else
        return "leetcode_normal"
    end
end

function theme.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("lc.colorscheme_sync", {}),
        desc = "Colorscheme Synchronizer",
        callback = theme.load,
    })

    theme.load()
end

return theme
