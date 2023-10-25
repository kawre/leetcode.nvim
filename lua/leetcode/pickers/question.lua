local log = require("leetcode.logger")

local Question = require("leetcode.ui.question")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param question lc.Cache.Question
---
---@return string
local function question_formatter(question)
    return string.format("%d. %s %s", question.frontend_id, question.title, question.title_slug)
end

---@param question lc.Cache.Question
local function display_difficulty(question)
    local hl = {
        ["Easy"] = "leetcode_easy",
        ["Medium"] = "leetcode_medium",
        ["Hard"] = "leetcode_hard",
    }

    return { "󱓻", hl[question.difficulty] }
end

---@param question lc.Cache.Question
local function display_user_status(question)
    if question.paid_only and not config.auth.is_premium then
        return { "", "leetcode_medium" }
    end

    local user_status = {
        ac = { "", "leetcode_easy" },
        notac = { "󱎖", "leetcode_medium" },
    }

    if question.status == vim.NIL then return { "" } end
    return user_status[question.status]
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
        { width = 1 },
        { width = 5 },
        { remaining = true },
    },
})

local function make_display(entry)
    ---@type lc.Cache.Question
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

local theme = require("telescope.themes").get_dropdown()

---@param questions lc.Cache.Question[]
---
---@return lc.Cache.Question[]
local function filter_questions(questions, opts)
    ---@param q lc.Cache.Question
    return vim.tbl_filter(function(q)
        for _, topic in ipairs(opts.topics) do
            if vim.tbl_contains(q.topic_tags, topic) then return true end
        end

        return q.difficulty == opts.diff or q.status == opts.status
    end, questions)
end

---@param sort_by string
---@param order "desc" | "asc"
local function sort_questions(questions, sort_by, order)
    local prod = order == "desc" and 1 or -1
    table.sort(questions, function(a, b) return (a[sort_by] > b[sort_by]) * prod end)
end

return {
    ---@param questions lc.Cache.Question[]
    pick = function(questions, opts)
        questions = filter_questions(questions, opts)
        sort_questions(questions, opts.sort_by, opts.order_by)

        pickers
            .new(theme, {
                prompt_title = "Select a Question",
                finder = finders.new_table({
                    results = questions,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(theme),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        if not selection then return end

                        local q = selection.value
                        if q.paid_only and not config.auth.is_premium then
                            log.warn("Question is for premium users only")
                            return
                        end

                        actions.close(prompt_bufnr)
                        Question:init(q)
                    end)
                    return true
                end,
            })
            :find()
    end,
}
