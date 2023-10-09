local config = require("leetcode.config")
local Pre = require("leetcode.ui.console.components.pre")

local NuiLine = require("nui.line")

local stdout = {}

---@param output string
---
---@return lc-ui.Text | nil
function stdout:init(output)
    local output_list = vim.split(output, "\n", { trimempty = true })

    local t = {}
    for i = 1, #output_list, 1 do
        table.insert(t, NuiLine():append(output_list[i]))
    end

    return Pre:init(NuiLine():append(" Stdout", "Comment"), t)
end

return stdout
