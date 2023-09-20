local log = require("leetcode.logger")
local Line = require("nui.line")
local utils = require("leetcode-ui.utils")

---@class lc.db.Component
---@field lines NuiLine[]
---@field opts lc.db.Component.config.opts
---@field type string
local component = {} ---@diagnostic disable-line
component.__index = component

--------------------------------------------------------
--- Methods
--------------------------------------------------------

---@param content NuiLine | string
---@param highlight? string
function component:append(content, highlight)
    if type(content) == "table" then
        table.insert(self.lines, content)
    else
        local line = Line():append(content, highlight)
        table.insert(self.lines, line)
    end

    return self
end

---@param split NuiSplit
function component:draw(split)
    local padding = utils.get_padding(self.lines, self.opts.position, split)

    for _, line in pairs(self.lines) do
        local new_line = Line()
        new_line:append(padding)
        new_line:append(line)

        new_line:render(split.bufnr, -1, line_idx, line_idx)

        line_idx = line_idx + 1
    end
end

return component
