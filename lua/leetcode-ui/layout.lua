local log = require("leetcode.logger")

---@class lc-ui.Layout
---@field contents lc-ui.Component[]
---@field opts lc-ui.Layout.opts
---@field line_idx? integer
---@field on_presses? table<integer, function>
local layout = {}
layout.__index = layout

---@alias bufnr integer Buffer number
---@type table<bufnr, lc-ui.Layout>
state = {} ---@diagnostic disable-line

---@param split NuiSplit
function layout:draw(split)
    state[split.bufnr] = self
    self.line_idx = 1

    for _, cmp in ipairs(self.contents) do
        cmp:draw(split)
    end
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

---@param config lc-ui.Layout
function layout:init(config)
    local obj = setmetatable({
        contents = config.contents,
        opts = config.opts,
        line_idx = 1,
        on_presses = {},
    }, self)

    return obj
end

return layout
