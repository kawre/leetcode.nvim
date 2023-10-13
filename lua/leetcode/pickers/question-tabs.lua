local log = require("leetcode.logger")
local utils = require("leetcode.utils")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param question lc.Cache.Question
---
---@return string
local function question_formatter(question)
    return string.format("%d. %s", question.frontend_id, question.title)
end

local function display_current(entry)
    local tabp = vim.api.nvim_get_current_tabpage()
    if tabp ~= entry.tabpage then return unpack({ "", "" }) end

    return { "", "" }
end

local function display_difficulty(q)
    local hl = {
        ["Easy"] = "leetcode_easy",
        ["Medium"] = "leetcode_medium",
        ["Hard"] = "leetcode_hard",
    }

    local lang = utils.get_lang(q.lang)
    return { lang.short, hl[q.q.difficulty] }
end

---@param question lc.Cache.Question
local function display_question(question)
    local index = { question.frontend_id .. ".", "leetcode_normal" }
    local title = { question.title }

    return unpack({ index, title })
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
        { width = 5 },
        { width = 5 },
        { remaining = true },
    },
})

local function make_display(entry)
    ---@type lc.Cache.Question
    local q = entry.value.question.q

    return displayer({
        display_current(entry.value),
        display_difficulty(entry.value.question),
        display_question(q),
    })
end

local function entry_maker(entry)
    return {
        value = entry,
        display = make_display,
        ordinal = question_formatter(entry.question.q),
    }
end

local opts = require("telescope.themes").get_dropdown()

return {
    pick = function()
        local tabs = utils.curr_question_tabs()
        if vim.tbl_isempty(tabs) then
            log.warn("No questions opened")
            return
        end

        pickers
            .new(opts, {
                prompt_title = "Select a Question",
                finder = finders.new_table({
                    results = tabs,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()

                        if not selection then return end
                        pcall(vim.cmd.tabnext, selection.value.tabpage)
                    end)
                    return true
                end,
            })
            :find()
    end,
}
