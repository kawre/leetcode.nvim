local Object = require("nui.object")
local Line = require("leetcode-ui.line")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@alias lines.params { lines: lc.ui.Line[], opts: lc-ui.Component.opts }

---@class lc-ui.Lines : lc.ui.Line
---@field _ lines.params
local Lines = Line:extend("LeetLines")

function Lines:contents()
    local lines = vim.deepcopy(self._.lines)

    if not vim.tbl_isempty(Lines.super.contents(self)) then
        table.insert(lines, Line(Lines.super.contents(self)))
    end

    return lines
end

local function create_pad(int)
    local lines = {}
    for _ = 1, int do
        local pad = Line()
        pad:append("")
        table.insert(lines, pad)
    end
    return lines
end

---@param layout lc-ui.Renderer
function Lines:draw(layout, opts)
    local lines = self:contents()

    opts = vim.tbl_deep_extend("force", self._.opts, opts or {})

    local padding = opts.padding

    local toppad = padding and padding.top
    if toppad then lines = vim.list_extend(create_pad(toppad), lines) end

    local botpad = padding and padding.bot
    if botpad then lines = vim.list_extend(lines, create_pad(botpad)) end

    local cpy = vim.deepcopy(self)
    cpy._.opts = opts

    local leftpad = utils.get_padding(cpy, layout)
    opts.padding.left = leftpad:len()

    for _, line in pairs(lines) do
        line:draw(layout, opts)
    end
end

function Lines:clear()
    Lines.super.clear(self)

    self._.lines = {}
    return self
end

function Lines:insert(item) --
    if not vim.tbl_isempty(self._texts) then self:endl() end

    table.insert(self._.lines, item)
    return self
end

function Lines:endl()
    local line = Line(Lines.super.contents(self))
    Lines.super.clear(self)
    self:insert(line)

    return self
end

function Lines:init(lines, opts)
    local options = vim.tbl_deep_extend("force", {
        padding = {},
        position = "left",
    }, opts or {})

    Lines.super.init(self, {}, options)

    self._.lines = lines or {}
end

---@type fun(lines: lc.ui.Line[],opts?: lc-ui.Component.opts): lc-ui.Lines
local LeetLines = Lines

return LeetLines
