local Component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")
local Padding = require("leetcode-ui.component.padding")
local log = require("leetcode.logger")

---@class lc-ui.Group: lc-ui.Component
---@field components lc-ui.Component[]
---@field opts lc-ui.Group.opts
local Group = {}
Group.__index = Group
setmetatable(Group, Component)

---@param config lc-ui.Group.config
---
---@return lc-ui.Group
function Group:init(config)
    local obj = setmetatable({
        components = config.components or {},
        opts = config.opts or {},
    }, self)

    return obj
end

---@param cmp lc-ui.Component | lc-ui.Component[]
---
---@return lc-ui.Group
function Group:append(cmp)
    if getmetatable(cmp) then
        table.insert(self.components, cmp)
    else
        self.lines = vim.list_extend(self.lines, cmp)
    end

    return self
end

---@param layout lc-ui.Layout
function Group:draw(layout)
    local components = vim.deepcopy(self.components)

    local padding = self.opts.padding
    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then Padding:init(toppad):draw(layout) end

    for i, component in pairs(components) do
        local opts = self.opts
        if opts.spacing and i ~= 1 then Padding:init(opts.spacing):draw(layout) end
        component:draw(layout)
    end

    if botpad then Padding:init(botpad):draw(layout) end
end

return Group
