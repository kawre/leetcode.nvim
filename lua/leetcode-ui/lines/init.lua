local Object = require("nui.object")
local Line = require("leetcode-ui.line")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@alias lines.params { lines: lc.ui.Line[], opts: lc-ui.Component.opts, line_idx: integer }

---@class lc-ui.Lines : NuiLine
---@field _ lines.params
local Lines = Object("LeetLines")

function Lines:set_opts(opts) --
    self._.opts = vim.tbl_deep_extend("force", self._.opts, opts or {})
end

function Lines:contents() return self._.lines end

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

    local padding = self._.opts.padding

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
    self._.lines = {}
    self._.line_idx = 1
    return self
end

function Lines:append(content, highlight)
    if not self._.lines[self._.line_idx] then table.insert(self._.lines, Line()) end

    self._.lines[self._.line_idx]:append(content, highlight or self._.opts.hl)
    return self
end

function Lines:insert(item) --
    table.insert(self._.lines, item)
    self._.line_idx = self._.line_idx + 1
    return self
end

function Lines:content() --
    return self:curr() and self:curr():content() or ""
end

function Lines:curr() --
    return self._.lines[self._.line_idx] or nil
end

function Lines:endl()
    if not self._.lines[self._.line_idx] then table.insert(self._.lines, Line()) end

    self._.line_idx = self._.line_idx + 1
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
    self._ = {
        opts = opts or {},
        line_idx = 1,
    }
    self:clear()
end

---@type fun(opts?: lc-ui.Component.opts): lc-ui.Lines
local LeetLines = Lines

return LeetLines
