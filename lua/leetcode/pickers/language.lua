local log = require("leetcode.logger")
local Question = require("leetcode.ui.question")
local problems_cache = require("leetcode.cache.problems")
local utils = require("leetcode.utils")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param snippet lc.QuestionCodeSnippet
---
---@return string
local function lang_formatter(snippet) return string.format("%s %s", snippet.t.lang, snippet.t.slug) end

---@param snippet lc.QuestionCodeSnippet
local function dislay_icon(snippet)
    local hl = "LeetCodeLang_" .. snippet.t.slug
    vim.api.nvim_set_hl(0, hl, { fg = snippet.t.color })

    return { snippet.t.icon, hl }
end

---@param snippet lc.QuestionCodeSnippet
local function display_lang(snippet)
    --
    return { snippet.lang }
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
        { remaining = true },
    },
})

local function make_display(entry)
    ---@type lc.QuestionCodeSnippet
    local snippet = entry.value

    return displayer({
        dislay_icon(snippet),
        display_lang(snippet),
    })
end

---@param entry lc.QuestionCodeSnippet
local function entry_maker(entry)
    ---@type lc.language
    entry.t = utils.get_lang(entry.lang_slug)
    if not entry.t then return end

    return {
        value = entry,
        display = make_display,
        ordinal = lang_formatter(entry),
    }
end

local opts = require("telescope.themes").get_dropdown()

return {
    ---@param question lc.Question
    pick = function(question)
        pickers
            .new(opts, {
                prompt_title = "Available Languages",
                finder = finders.new_table({
                    results = question.q.code_snippets,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        if not selection then return end
                        local snippet = selection.value

                        if question.lang == snippet.t.slug then
                            log.warn("Language already set to: " .. snippet.t.lang)
                            return
                        end

                        if snippet.t.sql then
                            config.sql = snippet.t.slug
                        else
                            config.lang = snippet.t.slug
                        end

                        actions.close(prompt_bufnr)
                        Question:init(question.cache)
                    end)
                    return true
                end,
            })
            :find()
    end,
}
