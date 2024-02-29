local log = require("leetcode.logger")
local t = require("leetcode.translator")
local utils = require("leetcode.utils")
local ui_utils = require("leetcode-ui.utils")

local Question = require("leetcode-ui.question")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param question lc.cache.Question
---
---@return string
local function question_formatter(question)
    return ("%s. %s %s %s"):format(
        tostring(question.frontend_id),
        question.title,
        question.title_cn,
        question.title_slug
    )
end

---@param question lc.cache.Question
local function display_difficulty(question)
    local hl = ui_utils.diff_to_hl(question.difficulty)
    return { config.icons.square, hl }
end

---@param question lc.cache.Question
local function display_user_status(question)
    if question.paid_only then
        return config.auth.is_premium and config.icons.hl.unlock or config.icons.hl.lock
    end

    if question.status == vim.NIL then
        return { "" }
    end
    return config.icons.hl.status[question.status] or { "" }
end

---@param question lc.cache.Question
local function display_question(question)
    local ac_rate = { ("%.1f%%"):format(question.ac_rate), "leetcode_ref" }
    local index = { question.frontend_id .. ".", "leetcode_normal" }

    local title = { utils.translate(question.title, question.title_cn) }

    return unpack({ index, title, ac_rate })
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
        { width = 1 },
        { width = 5 },
        { width = 78 },
        { width = 5 },
    },
})

local function make_display(entry)
    ---@type lc.cache.Question
    local q = entry.value

    return displayer({
        display_user_status(q),
        display_difficulty(q),
        display_question(q),
    })
end

local function entry_maker(entry)
    return {
        value = entry,
        display = make_display,
        ordinal = question_formatter(entry),
    }
end

local theme = require("telescope.themes").get_dropdown({
    layout_config = {
        width = 100,
        height = 20,
    },
})

---@param questions lc.cache.Question[]
---@param opts table<string, string[]>
---
---@return lc.cache.Question[]
local function filter_questions(questions, opts)
    if vim.tbl_isempty(opts or {}) then
        return questions
    end

    ---@param q lc.cache.Question
    return vim.tbl_filter(function(q)
        local diff_flag = true
        if opts.difficulty and not vim.tbl_contains(opts.difficulty, q.difficulty:lower()) then
            diff_flag = false
        end

        local status_flag = true
        if opts.status and not vim.tbl_contains(opts.status, q.status) then
            status_flag = false
        end

        return diff_flag and status_flag
    end, questions)
end

return {
    ---@param questions lc.cache.Question[]
    pick = function(questions, opts)
        pickers
            .new(theme, {
                prompt_title = t("Select a Question"),
                finder = finders.new_table({
                    results = filter_questions(questions, opts),
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(theme),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        if not selection then
                            return
                        end

                        local q = selection.value
                        if q.paid_only and not config.auth.is_premium then
                            return log.warn("Question is for premium users only")
                        end

                        actions.close(prompt_bufnr)
                        Question(q):mount()
                    end)

                    return true
                end,
            })
            :find()
    end,
}
