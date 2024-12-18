local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local language_picker = require("leetcode.picker.language")
local Picker = require("leetcode.picker")

local deli = "\t"

return function(question, cb)
    local items = language_picker.items(question.q.code_snippets)

    for i, item in ipairs(items) do
        local md = vim.inspect({ slug = item.value.t.slug, lang = item.value.t.lang })
            :gsub("\n", "")
        items[i] = table.concat({ Picker.normalize({ item })[1], md }, deli)
    end

    fzf.fzf_exec(items, {
        prompt = t("Available Languages") .. "> ",
        winopts = {
            height = language_picker.height,
            width = language_picker.width,
        },
        fzf_opts = {
            ["--delimiter"] = deli,
            ["--nth"] = "1",
            ["--with-nth"] = "1",
        },
        actions = {
            ["default"] = function(selected)
                local md = Picker.hidden_field(selected[1], deli)
                language_picker.select(load("return " .. md)(), question, cb)
            end,
        },
    })
end
