local log = require("leetcode.logger")
local NuiLine = require("nui.line")
local utils = require("leetcode-ui.utils")

---@class lc-ui.Component
---@field lines NuiLine[]
---@field opts lc-ui.Component.opts
---@field type string
local Component = {} ---@diagnostic disable-line
Component.__index = Component

--------------------------------------------------------
--- Methods
--------------------------------------------------------

---@param content NuiLine | string | NuiLine[]
---@param highlight? string
function Component:append(content, highlight)
    if type(content) == "string" then
        local line = NuiLine():append(content, highlight or "")
        table.insert(self.lines, line)
    elseif getmetatable(content) then
        table.insert(self.lines, content)
    else
        self.lines = vim.list_extend(self.lines, content)
    end

    return self
end

local function create_padding(val)
    local t = {}
    for _ = 1, val, 1 do
        table.insert(t, NuiLine():append(""))
    end

    return t
end

---@param layout lc-ui.Layout
function Component:draw(layout)
    local lines = self.lines

    local padding = self.opts.padding
    local toppad = padding and padding.top
    local leftpad = utils.get_padding(self, layout)
    local botpad = padding and padding.bot

    if toppad then lines = vim.list_extend(create_padding(toppad), lines) end
    if botpad then lines = vim.list_extend(lines, create_padding(botpad)) end

    for _, line in pairs(lines) do
        local new_line = NuiLine()
        new_line:append(leftpad)
        new_line:append(line)

        local line_idx = layout:get_line_idx(1)
        new_line:render(layout.bufnr, -1, line_idx, line_idx)

        -- self.on_press()
        if self.opts.on_press then layout:set_on_press(line_idx, self.opts.on_press) end
    end
end

function Component:clear() self.lines = {} end

Component.on_press = function() end

return Component
