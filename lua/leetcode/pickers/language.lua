local log = require("leetcode.logger")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param t lc.picker.language
---
---@return string
local function lang_formatter(t) return string.format("%s %s", t.icon, t.slug) end

---@param t lc.picker.language
local function dislay_icon(t)
    local name = "LeetCodeLang_" .. t.slug
    vim.api.nvim_set_hl(0, name, { fg = t.color })
    return { t.icon, name }
end

local function display_lang(t)
    --
    return t.lang
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 2 },
        { remaining = true },
    },
})

local function make_display(entry)
    ---@type lc.picker.language
    local q = entry.value

    return displayer({
        dislay_icon(q),
        display_lang(q),
    })
end

local function entry_maker(entry)
    return {
        value = entry,
        display = make_display,
        ordinal = lang_formatter(entry),
    }
end

local opts = require("telescope.themes").get_dropdown()

---@class lc.picker.language
---@field lang string
---@field slug string
---@field icon string
---@field color string

local languages = {
    { lang = "C++", slug = "cpp", icon = "", color = "#00599C" },
    { lang = "Java", slug = "java", icon = "", color = "#E76F00" },
    { lang = "Python", slug = "python", icon = "", color = "#306998" },
    { lang = "Python3", slug = "python3", icon = "", color = "#306998" },
    { lang = "C", slug = "c", icon = "", color = "#555555" },
    { lang = "C#", slug = "csharp", icon = "󰌛", color = "#68217A" },
    { lang = "JavaScript", slug = "javascript", icon = "", color = "#F0DB4F" },
    { lang = "TypeScript", slug = "typescript", icon = "", color = "#3178C6" },
    { lang = "PHP", slug = "php", icon = "", color = "#777BB4" },
    { lang = "Swift", slug = "swift", icon = "", color = "#FFAC45" },
    { lang = "Kotlin", slug = "kotlin", icon = "", color = "#7F52FF" },
    { lang = "Dart", slug = "dart", icon = "", color = "#1057A7" },
    { lang = "Go", slug = "golang", icon = "", color = "#00ADD8" },
    { lang = "Ruby", slug = "ruby", icon = "", color = "#CC342D" },
    { lang = "Scala", slug = "scala", icon = "", color = "#DC322F" },
    { lang = "Rust", slug = "rust", icon = "", color = "#DEA584" },
    { lang = "Racket", slug = "racket", icon = "󰰟", color = "#22228F" },
    { lang = "Erlang", slug = "erlang", icon = "", color = "#A90533" },
    { lang = "Elixir", slug = "elixir", icon = "", color = "#6E4A7E" },
}

return {
    pick = function()
        pickers
            .new(opts, {
                prompt_title = "Select a Language",
                finder = finders.new_table({
                    results = languages,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()

                        if not selection then return end
                        config.lang = selection.value.slug
                        log.info("Language set to " .. selection.value.lang)
                    end)
                    return true
                end,
            })
            :find()
    end,
}
