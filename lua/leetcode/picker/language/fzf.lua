local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local language_picker = require("leetcode.picker.language")
local Picker = require("leetcode.picker")

return function(question, cb)
    local items = Picker.normalize(language_picker.items(question.q.code_snippets))

    fzf.fzf_exec(items, {
        prompt = t("Available Languages") .. "> ",
        winopts = {
            win_height = language_picker.height,
            win_width = language_picker.width,
        },
        actions = {
            ["default"] = function(selected)
                print("You selected: " .. selected[1])
            end,
        },
    })
end
