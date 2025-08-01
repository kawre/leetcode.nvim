local log = require("leetcode.logger")
local t = require("leetcode.translator")
local question_picker = require("leetcode.picker.question")

local picker = require("snacks.picker")

---@param questions leet.cache.problem[]
return function(questions, opts)
    local items = question_picker.items(questions, opts)
    local finder_items = {}
    local completed = false

    for _, item in ipairs(items) do
        local text = question_picker.ordinal(item.value)
        table.insert(finder_items, {
            text = text,
            item = item,
        })
    end

    picker.pick({
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
            end, item.item.entry)
            return ret
        end,
        title = t("Select a Question"),
        layout = {
            preset = "select",
            preview = false,
            layout = {
                height = question_picker.height,
                width = question_picker.width,
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
                    question_picker.select(item.item.value)
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
