local log = require("leetcode.logger")
local Line = require("nui.line")
local utils = require("leetcode-ui.utils")

---@class lc-ui.Component
---@field lines NuiLine[]
---@field opts lc-ui.Component.config.opts
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
        local line = Line():append(content, highlight or "")
        table.insert(self.lines, line)
    end

    return self
end

---@param split NuiSplit | NuiPopup
function component:draw(split)
    local padding = utils.get_padding(self.lines, self.opts.position, split)
    local layout = state[split.bufnr]

    for _, line in pairs(self.lines) do
        -- log.info(line:content())
        local new_line = Line()
        new_line:append(padding)
        new_line:append(line)

        local line_idx = layout:get_line_idx(1)
        new_line:render(split.bufnr, -1, line_idx, line_idx)

        -- self.on_press()
        if self.opts.on_press then layout:set_on_press(line_idx, self.opts.on_press) end
    end
end

function component:clear() self.lines = {} end

component.on_press = function() end

return component
