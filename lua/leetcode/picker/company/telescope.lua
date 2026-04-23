local log = require("leetcode.logger")
local t = require("leetcode.translator")
local company_picker = require("leetcode.picker.company")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local displayer = entry_display.create({
    separator = " ",
    items = {
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
        ordinal = company_picker.ordinal(item.value),
    }
end

local theme = require("telescope.themes").get_dropdown({
    layout_config = {
        width = company_picker.width,
        height = company_picker.height,
    },
})

return function(companies)
    local items = {}
    for _, company in ipairs(companies) do
        local entry = company_picker.entry(company)
        table.insert(items, { entry = entry, value = company })
    end

    pickers
        .new(theme, {
            prompt_title = t("Select a Company"),
            finder = finders.new_table({
                results = items,
                entry_maker = entry_maker,
            }),
            sorter = conf.generic_sorter(theme),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if not selection then
                        log.warn("No selection")
                        return
                    end
                    company_picker.select(selection.value, function()
                        actions.close(prompt_bufnr)
                    end)
                end)
                return true
            end,
        })
        :find()
end
