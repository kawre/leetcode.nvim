local log = require("leetcode.logger")
local t = require("leetcode.translator")
local question_picker = require("leetcode.picker.question")

local Question = require("leetcode-ui.question")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local config = require("leetcode.config")

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
        { width = 1 },
        { width = 5 },
        { remaining = true },
        { remaining = true },
    },
})

local function entry_maker(item)
    return {
        value = item.value,
        display = function()
            return displayer(item.entry)
        end,
        ordinal = question_picker.ordinal(item.value),
    }
end

local theme = require("telescope.themes").get_dropdown({
    layout_config = {
        width = question_picker.width,
        height = question_picker.height,
    },
})

---@param questions lc.cache.Question[]
return function(questions, opts)
    local items = question_picker.items(questions, opts)

    pickers
        .new(theme, {
            prompt_title = t("Select a Question"),
            finder = finders.new_table({
                results = items,
                entry_maker = entry_maker,
            }),
            sorter = conf.generic_sorter(theme),
            attach_mappings = function(prompt_bufnr)
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
end
