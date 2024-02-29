local log = require("leetcode.logger")
local utils = require("leetcode.utils")
local ui_utils = require("leetcode-ui.utils")
local t = require("leetcode.translator")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")
local icons = config.icons

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param q lc.QuestionResponse
---
---@return string
local function question_formatter(q)
    return string.format("%s. %s %s", q.frontend_id, q.title, q.translated_title)
end

local function display_current(entry)
    local tabp = vim.api.nvim_get_current_tabpage()
    if tabp ~= entry.tabpage then
        return unpack({ "", "" })
    end

    return { icons.caret.right, "leetcode_ref" }
end

local function display_difficulty(q)
    local lang = utils.get_lang(q.lang)
    if not lang then
        return {}
    end
    return { lang.icon, "leetcode_lang_" .. lang.slug }
end

---@param question lc.QuestionResponse
local function display_question(question)
    local hl = ui_utils.diff_to_hl(question.difficulty)

    local index = { question.frontend_id .. ".", hl }
    local title = { utils.translate(question.title, question.translated_title) }

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
    ---@type lc.cache.Question
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
        local tabs = utils.question_tabs()

        if vim.tbl_isempty(tabs) then
            return log.warn("No questions opened")
        end

        -- table.sort(tabs, function(q1, q2)
        --     local fid1, fid2 =
        --         tonumber(q1.question.q.frontend_id), tonumber(q2.question.q.frontend_id)
        --     return (fid1 and fid2) and fid1 < fid2 or fid1 ~= nil
        -- end)

        pickers
            .new(opts, {
                prompt_title = t("Select a Question"),
                finder = finders.new_table({
                    results = tabs,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()

                        if not selection then
                            return
                        end
                        local ok, err =
                            pcall(vim.api.nvim_set_current_tabpage, selection.value.tabpage)
                        if not ok then
                            log.error(err)
                        end
                    end)
                    return true
                end,
            })
            :find()
    end,
}
