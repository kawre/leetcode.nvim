local Object = require("nui.object")
local Line = require("leetcode-ui.component.line")
-- local Pad = require("leetcode-ui.component.padding")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@class lc-ui.Lines : NuiLine
---@field _lines lc.ui.Line[]
---@field opts lc-ui.Component.opts
---@field _line_idx integer
local Lines = Object("LeetLines")

function Lines:set_opts(opts) --
    self.opts = vim.tbl_deep_extend("force", self.opts, opts or {})
end

function Lines:contents() return self._lines end

local function create_pad(int)
    local lines = {}
    for _ = 1, int do
        local pad = Line()
        pad:append("")
        table.insert(lines, pad)
    end
    return lines
end

---@param layout lc-ui.Layout
function Lines:draw(layout)
    local lines = vim.deepcopy(self:contents())

    local padding = self.opts.padding

    local toppad = padding and padding.top
    if toppad then lines = vim.list_extend(create_pad(toppad), lines) end

    local botpad = padding and padding.bot
    if botpad then lines = vim.list_extend(lines, create_pad(botpad)) end

    local leftpad = utils.get_padding(self, layout)

    for _, line in pairs(lines) do
        line:draw(layout, {
            padding = {
                left = leftpad:len(),
            },
        })
    end
end

function Lines:clear()
    self._lines = {}
    self._line_idx = 1
    return self
end

function Lines:append(content, highlight)
    if not self._lines[self._line_idx] then table.insert(self._lines, Line()) end

    self._lines[self._line_idx]:append(content, highlight or self.opts.hl)
    return self
end

function Lines:insert(item) --
    table.insert(self._lines, item)
    self._line_idx = self._line_idx + 1
    return self
end

function Lines:endl()
    if not self._lines[self._line_idx] then table.insert(self._lines, Line()) end

    self._line_idx = self._line_idx + 1
    return self
end

---@param lines table[]
function Lines:from(contents)
    for _, content in ipairs(contents) do
        self:append(content):endl()
    end

    return self
end

function Lines:init(opts)
    self.opts = opts or {}
    self:clear()
end

---@type fun(opts?: lc-ui.Component.opts): lc-ui.Lines
local LeetLines = Lines

return LeetLines
