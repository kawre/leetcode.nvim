local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local company_picker = require("leetcode.picker.company")
local Picker = require("leetcode.picker")

local deli = " "

return function(companies)
    local items = {}
    for _, company in ipairs(companies) do
        local entry = company_picker.entry(company)
        local normalized = Picker.normalize({ { entry = entry, value = company } })[1]
            .. deli
            .. Picker.apply_hl(company.slug, "leetcode_alt")
        table.insert(items, normalized)
    end

    fzf.fzf_exec(items, {
        prompt = t("Select a Company") .. "> ",
        winopts = {
            height = company_picker.height,
            width = company_picker.width,
        },
        fzf_opts = {
            ["--delimiter"] = deli,
            ["--nth"] = "3..-2",
        },
        actions = {
            ["default"] = function(selected)
                local slug = Picker.hidden_field(selected[1], deli)
                local company = nil
                for _, c in ipairs(companies) do
                    if c.slug == slug then
                        company = c
                        break
                    end
                end
                if company then
                    company_picker.select(company)
                end
            end,
        },
    })
end
