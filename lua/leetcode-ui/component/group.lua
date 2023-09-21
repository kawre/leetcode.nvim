local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")
local padding = require("leetcode-ui.component.padding")

---@class lc-ui.Group: lc-ui.Component
---@field components lc-ui.Component[]
---@field opts lc-ui.Group.config.opts
local group = {}
group.__index = group
setmetatable(group, component)

---@param config lc-ui.Group
---
---@return lc-ui.Group
function group:init(config)
    return setmetatable(config, self)

    -- self:append(config.components or {})
    -- self.components = config.components or {}
    -- self.opts = config.opts or {}
    --
    -- return o
end

---@param cmp lc-ui.Component | lc-ui.Component[]
---
---@return lc-ui.Group
function group:append(cmp)
    table.insert(self.components, cmp)

    return self
end

function group:draw(split)
    for i, cmp in pairs(self.components) do
        local opts = self.opts
        if opts.spacing and i ~= 1 then padding:init(opts.spacing):draw(split) end
        cmp:draw(split)
    end
end

return group
