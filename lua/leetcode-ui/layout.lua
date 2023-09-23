local log = require("leetcode.logger")
local Line = require("nui.line")

---@class lc-ui.Layout
---@field contents lc-ui.Component[]
---@field opts? lc-ui.Layout.opts
---@field line_idx? integer
---@field on_presses? table<integer, function>
local layout = {}
layout.__index = layout

---@alias bufnr integer Buffer number
---@type table<bufnr, lc-ui.Layout>
state = {} ---@diagnostic disable-line

---@param split NuiSplit | NuiPopup
function layout:draw(split)
    state[split.bufnr] = self
    self.line_idx = 1

    for _, cmp in pairs(self.contents) do
        cmp:draw(split)
    end
end

function layout:clear()
    self.contents = {}
    self.line_idx = 1
    self.on_presses = {}

    return self
end

---@param val? integer Optional value to increment line index by
function layout:get_line_idx(val)
    local line_idx = self.line_idx
    self.line_idx = self.line_idx + (val or 1)
    return line_idx
end

---@param line integer The line that the click happend
function layout:handle_press(line)
    if self.on_presses[line] then self.on_presses[line]() end
end

---@param line integer
---@param fn function
function layout:set_on_press(line, fn) self.on_presses[line] = fn end

---@param content lc-ui.Component
function layout:append(content)
    table.insert(self.contents, content)
    return self
end

---@param config? lc-ui.Layout
function layout:init(config)
    config = config or {}

    local obj = setmetatable({
        contents = config.contents or {},
        opts = config.opts or {},
        line_idx = 1,
        on_presses = {},
    }, self)

    return obj
end

return layout
