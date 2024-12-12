local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local tabs_picker = require("leetcode.picker.tabs")
local Picker = require("leetcode.picker")

local deli = "\t"

return function(tabs)
    local items = tabs_picker.items(tabs)

    for i, item in ipairs(items) do
        items[i] = Picker.normalize({ item })[1] .. deli .. item.value.tabpage
    end

    fzf.fzf_exec(items, {
        prompt = t("Select a Question") .. "> ",
        winopts = {
            height = tabs_picker.height,
            width = tabs_picker.width,
        },
        fzf_opts = {
            ["--delimiter"] = deli,
            ["--nth"] = "1",
            ["--with-nth"] = "1",
        },
        actions = {
            ["default"] = function(selected)
                local tabpage = Picker.hidden_field(selected[1], deli)
                tabs_picker.select({ tabpage = tonumber(tabpage) })
            end,
        },
    })
end
