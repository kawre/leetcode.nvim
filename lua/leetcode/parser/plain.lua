local Text = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local utils = require("leetcode.parser.utils")

---@class lc.Parser.Plain
---@field str string
---@field text lc-ui.Text
local Plain = {}
Plain.__index = Plain

function Plain:normalize() self.str = self.str:gsub("<[^>]+>", "") end

function Plain:trim()
    local lines = self.text.lines
    for i = #lines, 1, -1 do
        if lines[i]:content() ~= "" then break end
        table.remove(lines, i)
    end
    self.text.lines = lines

    return self.text
end

---@param html string
function Plain:parse(html)
    self = setmetatable({
        str = html,
        text = Text:init(),
    }, self)

    self:normalize()
    for s in vim.gsplit(self.str, "\n") do
        s = s:gsub("&[%a%d#]+;", function(match) return utils.entity(match) end)
        local nui_line = NuiLine()
        nui_line:append(s)
        self.text:append(nui_line)
    end

    return self:trim()
end

return Plain
