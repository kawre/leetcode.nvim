local log = require("leetcode.logger")
local t = require("leetcode.translator")
local company_picker = require("leetcode.picker.company")

local picker = require("snacks.picker")

return function(companies)
    local items = {}
    local completed = false

    for _, company in ipairs(companies) do
        local entry = company_picker.entry(company)
        local text = company_picker.ordinal(company)
        table.insert(items, {
            text = text,
            value = company,
        })
    end

    picker.pick({
        items = items,
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
        title = t("Select a Company"),
        layout = {
            preset = "select",
            preview = false,
            layout = {
                height = company_picker.height,
                width = company_picker.width,
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
                    company_picker.select(item.value)
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
