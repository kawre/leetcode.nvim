local Pad = require("leetcode-ui.lines.padding")
local Object = require("nui.object")
local Lines = require("leetcode-ui.lines")
local Line = require("leetcode-ui.line")

---@alias params { items: lc-ui.Lines[], opts: lc-ui.Group.opts, grp_idx: integer }

---@class lc-ui.Group
---@field _ params
local Group = Object("LeetGroup")

---@param opts lc-ui.Group.opts
function Group:set_opts(opts) --
    self._.opts = vim.tbl_deep_extend("force", self._.opts, opts or {})
end

function Group:contents() return self._.items end

function Group:append(content, highlight)
    if not self._.items[self._.grp_idx] then table.insert(self._.items, Lines()) end
    self._.items[self._.grp_idx]:append(content, highlight)
    return self
end

---@param layout lc-ui.Renderer
function Group:draw(layout, opts)
    opts = vim.tbl_deep_extend("force", self._.opts, opts or {})
    local margin = opts.margin
    local toppad = margin and margin.top
    local botpad = margin and margin.bot

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
    if self._.items[self._.grp_idx] then --
        self._.grp_idx = self._.grp_idx + 1
    end

    table.insert(self._.items, item)
    return self
end

function Group:endgrp()
    self._.grp_idx = self._.grp_idx + 1
    return self
end

function Group:clear()
    self._.items = {}
    self._.grp_idx = 1
    return self
end

--@param components lc-ui.Component[]
---@param opts? lc-ui.Group.opts
---
---@return lc-ui.Group
function Group:init(opts) --
    local options = vim.tbl_deep_extend("force", {
        margin = {},
    }, opts or {})

    self._ = {
        items = {},
        opts = options,
        grp_idx = 1,
    }
end

---@type fun(opts?: lc-ui.Group.opts): lc-ui.Group
local LeetGroup = Group

return LeetGroup
