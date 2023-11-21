local Padding = require("leetcode-ui.component.padding")
local Lines = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local log = require("leetcode.logger")

---@class lc-ui.Group : lc-ui.Text
---@field _items lc-ui.Text[]
---@field opts lc-ui.Group.opts
local Group = Lines:extend("LeetGroup")

---@param opts lc-ui.Group.opts
function Group:set_opts(opts) --
    self.opts = vim.tbl_deep_extend("force", self.opts, opts)
end

function Group:contents()
    local items = vim.deepcopy(self._items)

    if not vim.tbl_isempty(self.lines) or not vim.tbl_isempty(self._texts) then
        table.insert(items, Lines():from(Group.super.contents(self)))
    end

    return items
end

function Group:append(content, highlight)
    if content.__is_lines then
        table.insert(self._items, content)
    else
        Group.super.append(self, content, highlight)
    end

    return self
end

---@param layout lc-ui.Layout
function Group:draw(layout)
    log.debug("---- [DRAW GROUP START] " .. self.class.name)

    local padding = self.opts.padding
    local toppad = padding and padding.top
    local botpad = padding and padding.bot

    local items = self:contents()
    if toppad then Padding(toppad):draw(layout) end
    for _, item in ipairs(items) do
        log.debug("drawing .. " .. self.class.name .. "item: " .. item.class.name)
        item:draw(layout)
    end
    if botpad then Padding(botpad):draw(layout) end

    log.debug("---- [DRAW GROUP END] " .. self.class.name)
end

function Group:endgrp()
    if not vim.tbl_isempty(self.lines) or not vim.tbl_isempty(self._texts) then
        table.insert(self._items, vim.deepcopy(self))
    end
    self:clear()

    return self
end

--@param components lc-ui.Component[]
---@param opts? lc-ui.Group.opts
---
---@return lc-ui.Group
function Group:init(opts)
    Group.super.init(self, opts or {})

    self._items = {}
end

---@type fun(opts?: lc-ui.Group.opts): lc-ui.Group
local LeetGroup = Group

return LeetGroup
