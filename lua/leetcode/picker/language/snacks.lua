local log = require("leetcode.logger")
local t = require("leetcode.translator")
local picker = require("snacks.picker")

local language_picker = require("leetcode.picker.language")

---@param question lc.ui.Question
return function(question, cb)
    local items = language_picker.items(question.q.code_snippets)
    local finder_items = {}
    local completed = false

    for _, item in ipairs(items) do
        local text = language_picker.ordinal(item.value)
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
        title = t("Available Languages"),
        layout = {
            preview = false,
            preset = "select",
            layout = {
                height = language_picker.height,
                width = language_picker.width,
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
                    language_picker.select(item.item.value.t, question, cb)
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
