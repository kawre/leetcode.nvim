local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local question_picker = require("leetcode.picker.question")
local Picker = require("leetcode.picker")
local log = require("leetcode.logger")

return function(questions, opts)
    local items = Picker.normalize(question_picker.items(questions, opts))

    fzf.fzf_exec(items, {
        prompt = t("Select a Question") .. "> ",
        winopts = {
            win_height = question_picker.height,
            win_width = question_picker.width,
        },
        actions = {
            ["default"] = function(selected)
                print("You selected: " .. selected[1])
            end,
        },
    })
end
