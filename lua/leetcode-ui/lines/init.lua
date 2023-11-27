local Line = require("leetcode-ui.line")
local Opts = require("leetcode-ui.opts")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@alias lines.params { lines: lc.ui.Line[], opts: lc-ui.Component.opts }

---@class lc-ui.Lines : lc.ui.Line
---@field _ lines.params
local Lines = Line:extend("LeetLines")

function Lines:contents()
    local lines = self._.lines

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
    local options = Opts(self._.opts):merge(opts)
    local lines = vim.deepcopy(self:contents())

    local padding = options:get_padding()

    local toppad = padding and padding.top
    if toppad then lines = vim.list_extend(create_pad(toppad), lines) end

    local botpad = padding and padding.bot
    if botpad then lines = vim.list_extend(lines, create_pad(botpad)) end

    local copy = vim.deepcopy(self)
    copy._.opts = options:get()

    local leftpad = utils.get_padding(copy, layout)
    options:set({ padding = { left = leftpad:len() } })

    for _, line in pairs(lines) do
        line:draw(layout, options:get())
    end
end

function Lines:append(content, highlight)
    Lines.super.append(self, content, highlight)

    return self
end

function Lines:clear()
    Lines.super.clear(self)
    self._.lines = {}

    return self
end

function Lines:insert(item) --
    if not vim.tbl_isempty(Lines.super.contents(self)) then self:endl() end
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

---@type fun(lines?: lc.ui.Line[], opts?: lc-ui.Component.opts): lc-ui.Lines
local LeetLines = Lines

return LeetLines
