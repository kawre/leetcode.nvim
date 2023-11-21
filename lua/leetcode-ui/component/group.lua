local Pad = require("leetcode-ui.component.padding")
local Object = require("nui.object")
local Lines = require("leetcode-ui.component.text")
local Line = require("leetcode-ui.component.line")
local log = require("leetcode.logger")

---@alias params { items: lc-ui.Lines[], opts: lc-ui.Group.opts }

---@class lc-ui.Group
---@field _ params
local Group = Object("LeetGroup")

---@param opts lc-ui.Group.opts
function Group:set_opts(opts) --
    self.opts = vim.tbl_deep_extend("force", self.opts, opts)
end

function Group:contents() return self._.items end

function Group:append(content, highlight)
    self._.items[#self._.items]:append(content, highlight)
    return self
end

---@param layout lc-ui.Layout
function Group:draw(layout)
    log.debug("---- [DRAW GROUP START] " .. self.class.name)

    local opts = self._.opts
    local margin = opts.margin
    local toppad = margin and margin.top
    local botpad = margin and margin.bot

    if toppad then Pad(toppad):draw(layout) end

    local items = self:contents()
    for i, item in ipairs(items) do
        item:set_opts(opts)
        item:draw(layout)
        if i ~= #items then Pad(opts.spacing):draw(layout) end
    end

    if botpad then Pad(botpad):draw(layout) end

    log.debug("---- [DRAW GROUP END] " .. self.class.name)
end

---@param item lc-ui.Lines
function Group:insert(item) table.insert(self._.items, item) end

-- function Group:endgrp()
--     table.insert(self._.items, Line())
--     return self
-- end

function Group:clear() self._.items = {} end

--@param components lc-ui.Component[]
---@param opts? lc-ui.Group.opts
---
---@return lc-ui.Group
function Group:init(opts) --
    self._ = {
        items = {},
        opts = opts or {},
    }
end

---@type fun(opts?: lc-ui.Group.opts): lc-ui.Group
local LeetGroup = Group

return LeetGroup
