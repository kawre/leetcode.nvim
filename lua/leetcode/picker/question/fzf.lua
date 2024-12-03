local fzf = require("fzf-lua")
local problemlist = require("leetcode.cache.problemlist")
local t = require("leetcode.translator")
local question_picker = require("leetcode.picker.question")
local Picker = require("leetcode.picker")
local log = require("leetcode.logger")

local deli = " "

return function(questions, opts)
    local items = question_picker.items(questions, opts)

    for i, item in ipairs(items) do
        items[i] = Picker.normalize({ item })[1]
            .. deli
            .. Picker.apply_hl(item.value.title_slug, "Comment")
    end

    fzf.fzf_exec(items, {
        prompt = t("Select a Question") .. "> ",
        winopts = {
            win_height = question_picker.height,
            win_width = question_picker.width,
        },
        fzf_opts = {
            ["--delimiter"] = deli,
            ["--nth"] = "3..-3",
        },
        actions = {
            ["default"] = function(selected)
                local slug = string.match(selected[1], "([^ ]+)$")
                local question = problemlist.get_by_title_slug(slug)
                question_picker.select(question)
            end,
        },
    })
end
