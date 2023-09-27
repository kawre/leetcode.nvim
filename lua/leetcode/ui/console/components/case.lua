local log = require("leetcode.logger")
local Pre = require("leetcode.ui.console.components.pre")

local NuiLine = require("nui.line")

---@class lc.Result.Case
local case = {}

---@param index integer
---@param input string
---@param output string
---@param expected string
---
---@return lc-ui.Text
function case:init(index, input, output, expected)
    local t = {}

    local match = output == expected
    local icon = match and "" or ""
    local hi = match and "DiagnosticOk" or "DiagnosticError"
    local title_line = NuiLine():append(icon .. " Case " .. index, hi)

    local input_line = NuiLine()
    input_line:append("Input: ")
    input_line:append(input, "Comment")
    table.insert(t, input_line)

    local output_line = NuiLine()
    output_line:append("Output: ")
    output_line:append(output, "Comment")
    table.insert(t, output_line)

    local expected_line = NuiLine()
    expected_line:append("Expected: ")
    expected_line:append(expected, "Comment")
    table.insert(t, expected_line)

    return Pre:init(title_line, t)
end

return case
