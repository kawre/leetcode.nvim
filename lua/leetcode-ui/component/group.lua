local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")
local padding = require("leetcode-ui.component.padding")
---@class lc.db.Group: lc.db.Component
local group = {}
group.__index = group
setmetatable(group, component)

---@param config lc.db.Group.config
---
---@return lc.db.Group
function group:init(config)
    local o = setmetatable(config, self)
    self.__index = self

    -- self:append(config.components or {})
    self.components = config.components or {}
    self.opts = config.opts or {}

    return o
end

---@param cmp lc.db.Component | lc.db.Component[]
---
---@return lc.db.Group
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
