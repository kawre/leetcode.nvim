local log = require("leetcode.logger")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

log.info("sdf")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param t lc.picker.language
---
---@return string
local function lang_formatter(t) return string.format("%s %s", t.icon, t.slug) end

---@param t lc.picker.language
local function dislay_icon(t)
    --
    return t.icon
end

local function display_lang(t)
    --
    return t.lang
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
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

local languages = {
    { lang = "C++", slug = "cpp", icon = "" },
    { lang = "Java", slug = "java", icon = "" },
    { lang = "Python", slug = "python", icon = "" },
    { lang = "Python3", slug = "python3", icon = "" },
    { lang = "C", slug = "c", icon = "" },
    { lang = "C#", slug = "csharp", icon = "󰌛" },
    { lang = "JavaScript", slug = "javascript", icon = "" },
    { lang = "TypeScript", slug = "typescript", icon = "" },
    { lang = "PHP", slug = "php", icon = "" },
    { lang = "Swift", slug = "swift", icon = "" },
    { lang = "Kotlin", slug = "kotlin", icon = "" },
    { lang = "Dart", slug = "dart", icon = "" },
    { lang = "Go", slug = "golang", icon = "" },
    { lang = "Ruby", slug = "ruby", icon = "" },
    { lang = "Scala", slug = "scala", icon = "" },
    { lang = "Rust", slug = "rust", icon = "" },
    { lang = "Racket", slug = "racket", icon = "󰰟" },
    { lang = "Erlang", slug = "erlang", icon = "" },
    { lang = "Elixir", slug = "elixir", icon = "" },
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
                        config.lang = selection.slug
                        log.info("Language set to " .. selection.lang)
                    end)
                    return true
                end,
            })
            :find()
    end,
}
