local log = require("leetcode.logger")
local t = require("leetcode.translator")
local question_picker = require("leetcode.picker.question")

local picker = require("mini.pick")

---@param questions lc.cache.Question[]
return function(questions, opts)
    local question_items = question_picker.items(questions, opts)
    local ns_id = vim.api.nvim_create_namespace("MiniPick LeetCode Questions Picker")
    local finder_items = {}
    local completed = false

    for _, item in ipairs(question_items) do
        local text = question_picker.ordinal(item.value)
        table.insert(finder_items, {
            entry = item.entry,
            text = text,
            item = item,
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
                    question_picker.select(item.item.value)
                end)
            end,
            show = function(buf_id, items)
                require("leetcode.picker.mini_pick_utils").show_items(buf_id, ns_id, items)
            end,
        },
        window = {
            config = {
                width = question_picker.width,
                height = math.floor(vim.o.lines * question_picker.height),
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
