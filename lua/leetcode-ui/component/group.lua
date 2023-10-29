local Component = require("leetcode-ui.component")
local Padding = require("leetcode-ui.component.padding")

---@class lc-ui.Group: lc-ui.Component
---@field components lc-ui.Component[]
---@field opts lc-ui.Group.opts
local Group = {}
Group.__index = Group
setmetatable(Group, Component)

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

---@param components lc-ui.Component[]
---@param opts? lc-ui.Group.opts
---
---@return lc-ui.Group
function Group:init(components, opts)
    return setmetatable({
        components = components or {},
        opts = opts or {},
    }, self)
end

return Group
