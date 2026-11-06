local log = require("leetcode.logger")
local t = require("leetcode.translator")
local picker = require("mini.pick")

local langage_picker = require("leetcode.picker.language")

---@param question lc.ui.Question
return function(question, cb)
    local language_items = langage_picker.items(question.q.code_snippets)
    local ns_id = vim.api.nvim_create_namespace("MiniPick LeetCode Language Picker")
    local finder_items = {}
    local completed = false

    for _, item in ipairs(language_items) do
        local text = langage_picker.ordinal(item.value)
        table.insert(finder_items, {
            entry = item.entry,
            text = text,
            item = item,
        })
    end

    local res = picker.start({
        source = {
            items = finder_items,
            name = t("Available Languages"),
            choose = function(item)
                if completed then
                    return
                end
                completed = true
                vim.schedule(function()
                    langage_picker.select(item.item.value.t, question, cb)
                end)
            end,
            show = function(buf_id, items)
                require("leetcode.picker.mini_pick_utils").show_items(buf_id, ns_id, items)
            end,
        },
        window = {
            config = {
                width = langage_picker.width,
                height = langage_picker.height,
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
