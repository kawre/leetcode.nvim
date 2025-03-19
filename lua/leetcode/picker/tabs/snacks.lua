local log = require("leetcode.logger")
local t = require("leetcode.translator")
local tabs_picker = require("leetcode.picker.tabs")

local picker = require("snacks.picker")

return function(tabs)
    local items = tabs_picker.items(tabs)
    local finder_items = {}
    local completed = false
    local items_reflect = {}

    for _, item in ipairs(items) do
        items_reflect[item.value.question.q.frontend_id] = item.value
        local text = tabs_picker.ordinal(item.value.question.q)
        table.insert(finder_items, {
            entry = item.entry,
            item = item.value.question.q.frontend_id,
            text = text,
        })
    end

    picker.pick({
        source = "select",
        items = finder_items,
        format = function(item)
            local ret = {}
            vim.tbl_map(function(col)
                if type(col) == "table" then
                    ret[#ret + 1] = col
                else
                    ret[#ret + 1] = { col }
                end
                ret[#ret + 1] = { " " }
            end, item.entry)
            return ret
        end,
        title = t("Select a Question"),
        layout = {
            preview = false,
            layout = {
                height = math.floor(math.min(vim.o.lines * 0.8 - 10, #items + 2) + 0.5),
            },
        },
        actions = {
            confirm = function(p, item)
                if completed then
                    return
                end
                completed = true
                p:close()
                vim.schedule(function()
                    tabs_picker.select(items_reflect[item.item])
                end)
            end,
        },
        on_close = function()
            if completed then
                return
            end
            completed = true
            log.warn("No selection")
        end,
    })
end
