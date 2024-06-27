local t = require("leetcode.translator")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

---@param f lc.Favorite
---
---@return string
local function favorite_formatter(f)
    return string.format("%s - %s", f.slug, f.name)
end

---@param favorite lc.Favorite
local function display_favorite(favorite)
    return {
        favorite.name,
        favorite.slug,
    }
end

local displayer = entry_display.create({
    separator = " ",
    items = {
        { remaining = true },
    },
})

-- @param entry lc.Favorite
local function make_display(entry)
    ---@type lc.Favorite
    local f = entry.value

    return displayer({
        display_favorite(f),
    })
end

-- @param entry lc.Favorite
local function entry_maker(entry)
    return {
        value = entry,
        display = make_display,
        ordinal = favorite_formatter(entry),
    }
end

local opts = require("telescope.themes").get_dropdown()

return {
    pick = function(favorites, cb)
        pickers
            .new(opts, {
                prompt_title = t("Select a Favorite List"),
                finder = finders.new_table({
                    results = favorites,
                    entry_maker = entry_maker,
                }),
                sorter = conf.generic_sorter(theme),
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()

                        if not selection then
                            return
                        end
                        cb(selection.value)
                    end)
                    return true
                end,
            })
            :find()
    end,
}
