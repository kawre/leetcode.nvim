local log = require("leetcode.logger")
local Pre = require("leetcode.ui.console.components.pre")

local NuiLine = require("nui.line")

---@class lc.Result.Case
local case = {}

---@param index integer
---@param input string
---@param output string
---@param expected string
---@param passed? boolean
---
---@return lc-ui.Text
function case:init(index, input, output, expected, passed)
    local t = {}

    local match = passed or (output == expected)
    local icon = match and "" or ""
    local hi = match and "leetcode_ok" or "leetcode_error"
    local title_line = NuiLine()
    title_line:append(icon .. " Case " .. index, hi)

    local input_line = NuiLine()
    input_line:append("Input: ")
    input_line:append(input, "leetcode_alt")
    table.insert(t, input_line)

    local output_line = NuiLine()
    output_line:append("Output: ")
    output_line:append(output, "leetcode_alt")
    table.insert(t, output_line)

    local expected_line = NuiLine()
    expected_line:append("Expected: ")
    expected_line:append(expected, "leetcode_alt")
    table.insert(t, expected_line)

    return Pre:init(title_line, t)
end

return case
