local log = require("leetcode.logger")
local Text = require("leetcode-ui.component.text")
local Group = require("leetcode-ui.component.group")

local NuiText = require("nui.text")
local Line = require("leetcode-ui.component.line")
local Lines = require("leetcode-ui.component.text")

---@class lc.Result.Pre : lc-ui.Lines
local Pre = Lines:extend("LeetPre")

---@param title? lc.ui.Line
---@param lines lc.ui.Line[]
---
---@return lc-ui.Lines
function Pre:init(title, lines)
    Pre.super.init(self)

    if title then --
        self:append(title):endl():endl()
    end

    for _, line in ipairs(lines) do
        local new_line = Line({ NuiText("\t▎\t", "leetcode_indent") })
        new_line:append(line)
        self:append(new_line):endl()
    end
end

---@alias Pre.constructor fun(title: lc.ui.Line, lines: lc.ui.Line[]): lc.Result.Pre
---@type Pre.constructor
local LeetPre = Pre

return LeetPre
