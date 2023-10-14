---@class lc.Theme
local theme = {}

function theme.load()
    local default = require("leetcode.theme.default").get()
    for key, t in pairs(default) do
        key = "leetcode_" .. key
        vim.api.nvim_set_hl(0, key, t)
    end
end

return theme
