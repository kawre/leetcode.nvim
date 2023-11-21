local Padding = require("leetcode-ui.component.padding")
local Lines = require("leetcode-ui.component.text")

---@class lc-ui.Group : lc-ui.Text
---@field groups lc-ui.Text[]
---@field opts lc-ui.Group.opts
local Group = Lines:extend("LeetGroup")

---@param opts lc-ui.Group.opts
function Group:set_opts(opts) --
    self.opts = vim.tbl_deep_extend("force", self.opts, opts)
end

-- function Group:append(content, highlight) --
--     Group.super.append(self, content, highlight)
-- end

---@param layout lc-ui.Layout
function Group:draw(layout)
    if not vim.tbl_isempty(self._texts) then self:newgrp() end

    local groups = vim.deepcopy(self.groups)
    local opts = self.opts

    local padding = self.opts.padding
    local toppad = padding and padding.top
    local botpad = padding and padding.bot
    -- self.opts.padding = {}

    if toppad then Padding(toppad):draw(layout) end

    for i, group in pairs(groups) do
        if opts.spacing and i ~= 1 then Padding(opts.spacing):draw(layout) end
        Group.super.draw(group, layout)
    end

    if botpad then Padding(botpad):draw(layout) end
    -- self.opts.padding = padding
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
