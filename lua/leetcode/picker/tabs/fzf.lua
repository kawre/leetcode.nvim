local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local tabs_picker = require("leetcode.picker.tabs")
local Picker = require("leetcode.picker")

return function(tabs)
    local items = Picker.normalize(tabs_picker.items(tabs))

    fzf.fzf_exec(items, {
        prompt = t("Select a Question") .. "> ",
        actions = {
            ["default"] = function(selected)
                print("You selected: " .. selected[1])
            end,
        },
    })
end
