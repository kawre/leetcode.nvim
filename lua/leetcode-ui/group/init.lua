local Pad = require("leetcode-ui.lines.padding")
local Lines = require("leetcode-ui.lines")
local log = require("leetcode.logger")

---@alias lc.ui.Group.params { items: lc-ui.Lines[], opts: lc-ui.Group.opts }

---@class lc-ui.Group : lc-ui.Lines
---@field _ lc.ui.Group.params | lines.params
local Group = Lines:extend("LeetGroup")

function Group:contents()
    local items = vim.deepcopy(self._.items)

    if not vim.tbl_isempty(Group.super.contents(self)) then --
        table.insert(items, Lines(Group.super.contents(self)))
    end

    return items
end

---@param layout lc-ui.Renderer
function Group:draw(layout, opts)
    opts = vim.tbl_deep_extend("force", self._.opts, opts or {})
    local padding = vim.deepcopy(opts.padding)
    local toppad = padding and padding.top
    local botpad = padding and padding.bot
    opts.padding = {}

    if toppad then Pad(toppad):draw(layout) end

    local items = self:contents()
    for i, item in ipairs(items) do
        item:draw(layout, opts)
        if i ~= #items and opts.spacing then Pad(opts.spacing):draw(layout) end
    end

    if botpad then Pad(botpad):draw(layout) end
end

---@param item lc-ui.Lines
function Group:insert(item)
    if not vim.tbl_isempty(Group.super.contents(self)) then self:endgrp() end

    table.insert(self._.items, item)
    return self
end

function Group:endgrp()
    local lines = Lines(Group.super.contents(self))
    Group.super.clear(self)
    self:insert(lines)

    return self
end

function Group:clear()
    Group.super.clear(self)
    self._.items = {}

    return self
end

--@param components lc-ui.Component[]
---@param opts? lc-ui.Group.opts
---
---@return lc-ui.Group
function Group:init(items, opts) --
    local options = vim.tbl_deep_extend("force", {
        margin = {},
    }, opts or {})

    Group.super.init(self, {}, options)

    self._.items = items or {}
end

---@type fun(items: table, opts?: lc-ui.Group.opts): lc-ui.Group
local LeetGroup = Group

return LeetGroup
