local log = require("leetcode.logger")
local t = require("leetcode.translator")
local company_picker = require("leetcode.picker.company")

local picker = require("mini.pick")

return function(companies)
    local items = {}
    for _, company in ipairs(companies) do
        local entry = company_picker.entry(company)
        local text = company_picker.ordinal(company)
        table.insert(items, {
            entry = entry,
            text = text,
            value = company,
        })
    end

    local ns_id = vim.api.nvim_create_namespace("MiniPick LeetCode Companies Picker")

    picker.start({
        source = {
            items = items,
            name = t("Select a Company"),
            choose = function(item)
                vim.schedule(function()
                    company_picker.select(item.value)
                end)
                return true
            end,
            show = function(buf_id, source_items)
                require("leetcode.picker.mini_pick_utils").show_items(buf_id, ns_id, source_items)
            end,
        },
        window = {
            config = {
                width = company_picker.width,
                height = math.floor(vim.o.lines * company_picker.height),
            },
        },
    })
end
