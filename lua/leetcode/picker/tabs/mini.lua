local log = require("leetcode.logger")
local t = require("leetcode.translator")
local tabs_picker = require("leetcode.picker.tabs")

local picker = require("mini.pick")

return function(tabs)
    local tab_items = tabs_picker.items(tabs)
    local ns_id = vim.api.nvim_create_namespace("MiniPick LeetCode Tabs Picker")
    local finder_items = {}
    local completed = false
    local items_reflect = {}

    for _, item in ipairs(tab_items) do
        items_reflect[item.value.question.q.frontend_id] = item.value
        local text = tabs_picker.ordinal(item.value.question.q)
        table.insert(finder_items, {
            entry = item.entry,
            item = item.value.question.q.frontend_id,
            text = text,
        })
    end

    local res = picker.start({
        source = {
            items = finder_items,
            name = t("Select a Question"),
            choose = function(item)
                if completed then
                    return
                end
                completed = true
                vim.schedule(function()
                    tabs_picker.select(items_reflect[item.item])
                end)
            end,
            show = function(buf_id, items)
                require("leetcode.picker.mini_pick_utils").show_items(buf_id, ns_id, items)
            end,
        },
        window = {
            config = {
                width = tabs_picker.width,
                height = tabs_picker.height,
            },
        },
    })

    if res == nil then
        if completed then
            return
        end
        completed = true
        log.warn("No selection")
    end
end
