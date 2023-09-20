local log = require("leetcode.logger")

---@class lc.db.Layout
---@field contents lc.db.Component[]
---@field opts lc.db.Layout.opts
local layout = {}
layout.__index = layout

---@param split NuiSplit
function layout:draw(split)
    for _, component in ipairs(self.contents) do
        component:draw(split)
    end
end

---@param config lc.db.Layout.config
function layout:init(config)
    local o = setmetatable(config, self)

    self.contents = config.contents
    self.opts = config.opts

    return o
end

return layout
