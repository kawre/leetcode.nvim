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

local opts = require("telescope.themes").get_dropdown({
    layout_config = {
        width = language_picker.width,
        height = language_picker.height,
    },
})

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
                        log.warn("No selection")
                        return
                    end

                    language_picker.select(selection.value, question, cb, function()
                        actions.close(prompt_bufnr)
                    end)
                end)

                return true
            end,
        })
        :find()
end
