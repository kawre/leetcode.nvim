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
    local hi = {
        ["Easy"] = { "E", "LeetCodeEasy" },
        ["Medium"] = { "M", "LeetCodeMedium" },
        ["Hard"] = { "H", "LeetCodeHard" },
    }

    return { "󱓻", "LeetCode" .. question.difficulty }
end

---@param question lc.Cache.Question
local function display_user_status(question)
    if question.paid_only and not config.auth.is_premium then return { "", "LeetCodeMedium" } end

    local user_status = {
        ac = { "", "LeetCodeEasy" },
        notac = { "󱎖", "LeetCodeMedium" },
    }

    if question.status == vim.NIL then return { "" } end
    return user_status[question.status]
end

---@param question lc.Cache.Question
local function display_question(question)
    local index = { question.frontend_id .. ".", "LeetCodeNormal" }
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

local opts = require("telescope.themes").get_dropdown()

return {
    ---@param questions lc.Cache.Question[]
    pick = function(questions)
        pickers
            .new(opts, {
                prompt_title = "Select a Question",
                finder = finders.new_table({
                    results = questions,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(opts),
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
