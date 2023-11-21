local Padding = require("leetcode-ui.component.padding")
local Lines = require("leetcode-ui.component.text")

---@class lc-ui.Group : lc-ui.Text
---@field groups lc-ui.Text[]
---@field opts lc-ui.Group.opts
local Group = Lines:extend("LeetGroup")

---@param opts lc-ui.Group.opts
function Group:set_opts(opts) self.opts = vim.tbl_deep_extend("force", self.opts, opts) end

---@param layout lc-ui.Layout
function Group:draw(layout)
    local components = vim.deepcopy(self.groups)

    local padding = self.opts.padding
    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then Padding(toppad):draw(layout) end

    for i, component in pairs(components) do
        local opts = self.opts
        if opts.spacing and i ~= 1 then Padding(opts.spacing):draw(layout) end
        -- component:draw(layout)
        Group.super.draw(component, layout)
    end

    if botpad then Padding(botpad):draw(layout) end
end

function Group:newgrp()
    table.insert(self.groups, vim.deepcopy(self))
    self:clear()
end

--@param components lc-ui.Component[]
---@param opts? lc-ui.Group.opts
---
---@return lc-ui.Group
function Group:init(opts)
    Group.super.init(self, opts or {})

    self.groups = {}
end

---@type fun(opts?: lc-ui.Group.opts): lc-ui.Group
local LeetGroup = Group

return LeetGroup
