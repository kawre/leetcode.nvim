local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
local config = require("leetcode.config")

---@class lc.Theme
local theme = {}

function theme.load_icons()
    vim.tbl_map(function(l)
        local icon, color = devicons.get_icon_color(l.ft)

        if icon then l.icon = icon end
        if color then l.color = color end

        return l
    end, config.langs)
end

function theme.load()
    local default = require("leetcode.theme.default").get()
    for key, t in pairs(default) do
        key = "leetcode_" .. key
        vim.api.nvim_set_hl(0, key, t)
    end

    if devicons_ok then theme.load_icons() end

    for _, lang in ipairs(config.langs) do
        local name = "leetcode_lang_" .. lang.slug
        vim.api.nvim_set_hl(0, name, { fg = lang.color })
    end
end

return theme
