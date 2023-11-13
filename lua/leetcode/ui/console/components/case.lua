local log = require("leetcode.logger")
local t = require("leetcode.translator")
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
    local tbl = {}

    local match = passed or (output == expected)
    local icon = match and "" or ""
    local hi = match and "leetcode_ok" or "leetcode_error"
    local title_line = NuiLine()
    title_line:append(icon .. " Case " .. index, hi)

    local input_line = NuiLine()
    input_line:append(("%s: "):format(t("Input")))
    input_line:append(input, "leetcode_alt")
    table.insert(tbl, input_line)

    local output_line = NuiLine()
    output_line:append(("%s: "):format(t("Output")))
    output_line:append(output, "leetcode_alt")
    table.insert(tbl, output_line)

    local expected_line = NuiLine()
    expected_line:append(("%s: "):format(t("Expected")))
    expected_line:append(expected, "leetcode_alt")
    table.insert(tbl, expected_line)

    return Pre:init(title_line, tbl)
end

return case
