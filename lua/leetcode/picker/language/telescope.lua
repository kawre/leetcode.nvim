local log = require("leetcode.logger")
local t = require("leetcode.translator")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local language_picker = require("leetcode.picker.language")

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
        { remaining = true },
    },
})

local function entry_maker(item)
    return {
        value = item.value,
        display = function()
            return displayer(item.entry)
        end,
        ordinal = language_picker.ordinal(item.value),
    }
end

local opts = require("telescope.themes").get_dropdown()

---@param question lc.ui.Question
return function(question, cb)
    local items = language_picker.items(question.q.code_snippets)

    pickers
        .new(opts, {
            prompt_title = t("Available Languages"),
            finder = finders.new_table({
                results = items,
                entry_maker = entry_maker,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if not selection then
                        return
                    end

                    local snippet = selection.value
                    if question.lang == snippet.t.slug then
                        return log.warn(
                            ("%s: %s"):format(t("Language already set to"), snippet.t.lang)
                        )
                    end

                    config.lang = snippet.t.slug
                    actions.close(prompt_bufnr)

                    if cb then
                        cb(snippet)
                    else
                        question:change_lang(snippet.t.slug)
                    end
                end)

                return true
            end,
        })
        :find()
end
