local config = require("leetcode.config")
local NuiLine = require("nui.line")
local log = require("leetcode.logger")
local Pre = require("leetcode.ui.console.components.pre")

local stdout = {}

---@param item interpreter_response
---@param case_idx integer
---
---@return lc-ui.Text | nil
function stdout:init(case_idx, item)
    if item.std_output_list[case_idx] == "" then return nil end

    local output_list = vim.split(item.std_output_list[case_idx], "\n", { trimempty = true })
    local max_stdout_len = config.user.console.result.max_stdout_length
    local stdout_len = #output_list

    local t = {}
    for i = 1, math.min(max_stdout_len, stdout_len), 1 do
        table.insert(t, NuiLine():append(output_list[i]))
    end

    if stdout_len > max_stdout_len then
        local diff = stdout_len - max_stdout_len
        table.insert(t, NuiLine():append("… " .. diff .. " more lines"))
    end

    return Pre:init(NuiLine():append(" Stdout", "Comment"), t)
end

return stdout
