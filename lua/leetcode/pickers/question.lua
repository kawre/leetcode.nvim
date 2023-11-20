local log = require("leetcode.logger")
local t = require("leetcode.translator")
local utils = require("leetcode.utils")

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
    return ("%s. %s %s %s"):format(
        tostring(question.frontend_id),
        question.title,
        question.title_cn,
        question.title_slug
    )
end

---@param question lc.Cache.Question
local function display_difficulty(question)
    local hl = {
        ["Easy"] = "leetcode_easy",
        ["Medium"] = "leetcode_medium",
        ["Hard"] = "leetcode_hard",
    }

    return { "󱓻", hl[question.difficulty] or "" }
end

---@param question lc.Cache.Question
local function display_user_status(question)
    if question.paid_only and not config.auth.is_premium then
        return { "", "leetcode_medium" }
    end

    local user_status = {
        ac = { "", "leetcode_easy" },
        notac = { "󱎖", "leetcode_medium" },
        todo = { "", "leetcode_alt" },
    }

    if question.status == vim.NIL then return { "" } end
    return user_status[question.status] or { "" }
end

---@param question lc.Cache.Question
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

local theme = require("telescope.themes").get_dropdown({
    layout_config = {
        width = 100,
        height = 20,
    },
})

---@param questions lc.Cache.Question[]
---@param opts table<string, string[]>
---
---@return lc.Cache.Question[]
local function filter_questions(questions, opts)
    if vim.tbl_isempty(opts or {}) then return questions end

    ---@param q lc.Cache.Question
    return vim.tbl_filter(function(q)
        -- if opts.topics then
        --     for _, topic in ipairs(opts.topics) do
        --         local flag = false
        --
        --         for _, tag in ipairs(q.topic_tags) do
        --             if tag.slug == topic then
        --                 flag = true
        --                 break
        --             end
        --         end
        --
        --         if not flag then return false end
        --     end
        -- end

        if opts.difficulty then
            if not vim.tbl_contains(opts.difficulty, q.difficulty) then return false end
        end

        if opts.status then
            if not vim.tbl_contains(opts.status, q.status) then return false end
        end

        return true
    end, questions)
end

return {
    ---@param questions lc.Cache.Question[]
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
