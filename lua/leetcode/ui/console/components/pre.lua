local log = require("leetcode.logger")
local Text = require("leetcode-ui.component.text")
local Group = require("leetcode-ui.component.group")

local NuiText = require("nui.text")
local Line = require("leetcode-ui.component.line")

---@class lc.Result.Pre
local pre = {}
pre.__index = pre

---@param title? NuiLine|NuiText
---@param lines NuiLine[]
---
---@return lc-ui.Lines
function pre:init(title, lines)
    local text = Text({})
    if title then text:append({ title, Line() }) end

    for _, line in ipairs(lines) do
        local new_line = Line({ NuiText("\t▎\t", "leetcode_indent") })
        new_line:append(line)
        text:append(new_line)
    end

    return text
end

return pre
