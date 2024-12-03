local log = require("leetcode.logger")
local t = require("leetcode.translator")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local tabs_picker = require("leetcode.picker.tabs")
local action_state = require("telescope.actions.state")

local displayer = entry_display.create({
    separator = " ",
    items = {
        { width = 1 },
        { width = 1 },
        { width = 5 },
        { remaining = true },
    },
})

local function entry_maker(item)
    return {
        value = item.value,
        display = function()
            return displayer(item.entry)
        end,
        ordinal = tabs_picker.ordinal(item.value.question.q),
    }
end

local opts = require("telescope.themes").get_dropdown()

return function(tabs)
    local items = tabs_picker.items(tabs)

    pickers
        .new(opts, {
            prompt_title = t("Select a Question"),
            finder = finders.new_table({
                results = items,
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
                    local ok, err = pcall(vim.api.nvim_set_current_tabpage, selection.value.tabpage)
                    if not ok then
                        log.error(err)
                    end
                end)
                return true
            end,
        })
        :find()
end
