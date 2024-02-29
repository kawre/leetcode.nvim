local Pad = require("leetcode-ui.lines.padding")
local Lines = require("leetcode-ui.lines")
local Opts = require("leetcode-ui.opts")
local O = require("nui.object")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@alias lc.ui.Group.params { items: lc.ui.Lines[], opts: lc.ui.opts }

---@class lc.ui.Group : lc.ui.Lines
---@field _ lc.ui.Group.params | lines.params
local Group = Lines:extend("LeetGroup")

function Group:lines()
    local tbl = {}
    for _, item in ipairs(self:contents()) do
        self:lines_helper(item, tbl)
    end
    return tbl
end

---@private
---@param tbl table
function Group:lines_helper(item, tbl) --
    if item.class and item.class.name == "LeetLine" then
        table.insert(tbl, item)
        return
    end

    for _, c in ipairs(item:contents()) do
        self:lines_helper(c, tbl)
    end
end

function Group:contents()
    local items = utils.shallowcopy(self._.items)

    local contents = Group.super.contents(self)
    if not vim.tbl_isempty(contents) then
        table.insert(items, Lines(contents))
    end

    return items
end

---@param layout lc.ui.Renderer
function Group:draw(layout, opts)
    local options = Opts(self._.opts):merge(opts)

    local padding = options:get_padding()
    local spacing = options:get_spacing()

    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    if toppad then
        Pad(toppad):draw(layout)
    end

    local items = self:contents()
    for i, item in ipairs(items) do
        item:draw(layout, options:get())
        if i ~= #items and spacing then
            Pad(spacing):draw(layout)
        end
    end

    if botpad then
        Pad(botpad):draw(layout)
    end
end

---@param item lc.ui.Lines
function Group:insert(item)
    if not vim.tbl_isempty(Group.super.contents(self)) then
        self:endgrp()
    end
    table.insert(self._.items, item)

    return self
end

function Group:append(content, highlight)
    if type(content) == "table" and O.is_instance(content, Group) then
        local items = content:contents()

        for _, item in ipairs(items) do
            Group.super.append(self, item, highlight)
        end
    else
        Group.super.append(self, content, highlight)
    end

    return self
end

function Group:endgrp()
    local contents = Group.super.contents(self)

    if not vim.tbl_isempty(contents) then
        table.insert(self._.items, Lines(contents))
        Group.super.clear(self)
    else
        Group.super.clear(self)
    end

    return self
end

function Group:clear()
    Group.super.clear(self)
    self._.items = {}

    return self
end

function Group:replace(items)
    self:clear()
    self._.items = items

    return self
end

--@param components lc-ui.Component[]
---@param opts? lc.ui.opts
---
---@return lc.ui.Group
function Group:init(items, opts) --
    local options = vim.tbl_deep_extend("force", {}, opts or {})

    Group.super.init(self, {}, options)

    self._.items = items or {}
end

---@type fun(items?: table, opts?: lc.ui.opts): lc.ui.Group
local LeetGroup = Group

return LeetGroup
