local NuiLine = require("nui.line")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@class lc-ui.Text : NuiLine
---@field lines NuiLine[]
---@field opts lc-ui.Component.opts
local Lines = NuiLine:extend("LeetLines")

local function create_padding(val)
    local tbl = {}
    for _ = 1, val, 1 do
        table.insert(tbl, NuiLine():append(""))
    end

    return tbl
end

function Lines:set_opts(opts) --
    self.opts = vim.tbl_deep_extend("force", self.opts, opts or {})
end

---@param layout lc-ui.Layout
function Lines:draw(layout)
    if not vim.tbl_isempty(self._texts) then self:endl() end
    local lines = self.lines

    local padding = self.opts.padding
    local toppad = padding and padding.top
    local leftpad = utils.get_padding(self, layout)
    local botpad = padding and padding.bot

    if toppad then lines = vim.list_extend(create_padding(toppad), lines) end
    if botpad then lines = vim.list_extend(lines, create_padding(botpad)) end

    for _, line in pairs(lines) do
        local new_line = NuiLine()
        new_line:append(leftpad)
        new_line:append(line)

        local line_idx = layout:get_line_idx(1)
        new_line:render(layout._.bufnr, -1, line_idx, line_idx)

        if self.opts.on_press then
            layout:set_on_press(line_idx, self.opts.on_press, self.opts.sc)
        end
    end
end

function Lines:clear() self.lines = {} end

function Lines:append(content, highlight)
    if content.lines then
        for _, line in ipairs(content.lines) do
            Lines.super.append(self, line, highlight or self.opts.hl)
            self:endl()
        end
    else
        Lines.super.append(self, content, highlight or self.opts.hl)
    end

    return self
end

function Lines:endl()
    table.insert(self.lines, vim.deepcopy(self))
    self._texts = {}
    return self
end

---@param lines table[]
function Lines:from(lines)
    for _, line in ipairs(lines) do
        self:append(line):endl()
    end

    return self
end

function Lines:init(opts)
    Lines.super.init(self)

    self.opts = opts or {}
    self.lines = {}
end

---@type fun(opts?: lc-ui.Component.opts): lc-ui.Component
local LeetLines = Lines

return LeetLines
