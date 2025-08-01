local fzf = require("fzf-lua")
local problemlist = require("leetcode.cache.problems")
local t = require("leetcode.translator")
local question_picker = require("leetcode.picker.question")
local Picker = require("leetcode.picker")

local deli = " "

return function(questions, opts)
    local items = question_picker.items(questions, opts)

    for i, item in ipairs(items) do
        items[i] = Picker.normalize({ item })[1]
            .. deli
            .. Picker.apply_hl(item.value.title_slug, "leetcode_alt")
    end

    fzf.fzf_exec(items, {
        prompt = t("Select a Question") .. "> ",
        winopts = {
            height = question_picker.height,
            width = question_picker.width,
        },
        fzf_opts = {
            ["--delimiter"] = deli,
            ["--nth"] = "3..-3",
        },
        actions = {
            ["default"] = function(selected)
                local slug = Picker.hidden_field(selected[1], deli)
                local question = problemlist.by_slug(slug)
                question_picker.select(question)
            end,
        },
    })
end
