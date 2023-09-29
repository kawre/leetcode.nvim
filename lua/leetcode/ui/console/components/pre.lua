local log = require("leetcode.logger")
local Text = require("leetcode-ui.component.text")
local Group = require("leetcode-ui.component.group")

local NuiText = require("nui.text")
local NuiLine = require("nui.line")

---@class lc.Result.Pre
local pre = {}
-- pre.__index = pre

---@param title NuiText | NuiLine
---@param lines NuiLine[]
---
---@return lc-ui.Text
function pre:init(title, lines)
    local text = Text:init({ lines = { title, NuiLine() } })

    for _, line in ipairs(lines) do
        local new_line = NuiLine({ NuiText("\t▎\t", "LeetCodeIndent") })
        new_line:append(line)
        text:append(new_line)
    end

    return text

    -- local obj = setmetatable({
    --
    -- }, self)
    -- return group

    -- return obj
    -- table.insert(t, NuiLine())
    -- local match = output == expected
    -- local icon = match and "" or ""
    -- local hi = match and "LeetCodeOk" or "LeetCodeError"
    -- local index_line = NuiLine():append(icon .. " Case " .. index, hi)
    -- table.insert(t, index_line)
    --
    -- local indent = "\t▎\t"
    --
    -- table.insert(t, NuiLine())
    --
    -- local input_line = NuiLine():append(indent .. "Input: " .. input)
    -- table.insert(t, input_line)
    --
    -- local output_line = NuiLine():append(indent .. "Output: " .. output)
    -- table.insert(t, output_line)
    --
    -- local expected_line = NuiLine():append(indent .. "Expected: " .. expected)
    -- table.insert(t, expected_line)
end

return pre
