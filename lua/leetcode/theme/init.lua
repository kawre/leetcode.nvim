local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
local log = require("leetcode.logger")
local config = require("leetcode.config")
local default = require("leetcode.theme.default")

---@class lc.Theme
local Theme = {}

---@type table<string, string[]>
local dynamic_hls = {}

-- by default tags use `normal` theme
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

    sup = "su",
    sub = "su",

    -- pre = "",
    -- span = "",
    -- p = "",
    -- ul = "",
    -- ol = "",
    -- li = "",
    -- font = "",
    -- small = "",
    -- div = "",
}

function Theme.load_devicons()
    ---@param l lc.language
    vim.tbl_map(function(l)
        local icon, color = devicons.get_icon_color(l.ft)

        if icon then
            l.icon = icon
        end
        if color then
            l.color = color
        end

        return l
    end, config.langs)
end

function Theme.load()
    config.theme = vim.tbl_extend("force", default.get(), config.user.theme)

    for key, t in pairs(config.theme) do
        key = "leetcode_" .. key
        vim.api.nvim_set_hl(0, key, t)
    end

    if devicons_ok then
        Theme.load_devicons()
    end

    ---@param lang lc.language
    vim.tbl_map(function(lang)
        local name = "leetcode_lang_" .. lang.slug
        vim.api.nvim_set_hl(0, name, { fg = lang.color })
        lang.hl = name

        return lang
    end, config.langs)

    Theme.load_dynamic()
end

function Theme.load_dynamic()
    for name, tags in pairs(dynamic_hls) do
        Theme.create_dynamic(name, tags)
    end
end

---@param tags string[]
function Theme.get_dynamic(tags)
    if vim.tbl_isempty(tags) then
        return "leetcode_normal"
    end

    local name = "leetcode_dyn_" .. table.concat(tags, "_")
    if dynamic_hls[name] then
        return name
    end

    return Theme.create_dynamic(name, tags)
end

---@param name string
---@param tags string[]
function Theme.create_dynamic(name, tags)
    local theme = config.theme

    local tbl = theme["normal"]
    for _, tag in ipairs(tags) do
        local hl = highlights[tag]
        if hl then
            tbl = vim.tbl_extend("force", tbl, theme[hl])
        end
    end

    if tbl.italic or tbl.bold then
        if tbl.fg == theme["normal"].fg then
            tbl.fg = theme[""].fg
        end
    end

    if pcall(vim.api.nvim_set_hl, 0, name, tbl) then
        dynamic_hls[name] = tags
        return name
    else
        return "leetcode_normal"
    end
end

function Theme.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("lc.colorscheme_sync", {}),
        desc = "Colorscheme Synchronizer",
        callback = Theme.load,
    })

    Theme.load()
end

return Theme
