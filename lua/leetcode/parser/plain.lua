local Lines = require("leetcode-ui.lines")
local Line = require("leetcode-ui.line")
local utils = require("leetcode-ui.group.parser.utils")

---@class lc.Parser.Plain
---@field str string
---@field lines lc.ui.Lines
local Plain = {}
Plain.__index = Plain

function Plain:normalize() self.str = self.str:gsub("<[^>]+>", "") end

function Plain:trim()
    local lines = self.lines._.lines
    for i = #lines, 1, -1 do
        if lines[i]:content() ~= "" then break end
        table.remove(lines, i)
    end
    self.lines._.lines = lines

    return self.lines
end

---@param html string
function Plain:parse(html)
    self = setmetatable({
        str = html,
        lines = Lines(),
    }, self)

    self:normalize()
    for s in vim.gsplit(self.str, "\n") do
        s = s:gsub("&[%a%d#]+;", function(match) return utils.entity(match) end)
        local line = Line()
        line:append(s)
        self.lines:insert(line)
    end

    return self:trim()
end

return Plain
