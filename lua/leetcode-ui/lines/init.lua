local Line = require("leetcode-ui.line")
local Opts = require("leetcode-ui.opts")
local O = require("nui.object")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@alias lines.params { lines: lc.ui.Line[], opts: lc.ui.opts }

---@class lc.ui.Lines : lc.ui.Line
---@field _ lines.params
local Lines = Line:extend("LeetLines")

function Lines:contents()
    local lines = utils.shallowcopy(self._.lines)

    local contents = Lines.super.contents(self)
    if not vim.tbl_isempty(contents) then
        table.insert(lines, Line(contents))
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

function Lines:get_leftpad(renderer, opts) --
    local padding = (opts.padding or {}).left or 0

    local position = opts.position
    if position ~= "left" and vim.api.nvim_win_is_valid(renderer.winid or -1) then
        local max_len, win_width = self:longest(), utils.win_width(renderer)

        if position == "center" then
            padding = (win_width - max_len) / 2
        elseif position == "right" then
            padding = win_width - max_len - 1
        end
    end

    return math.floor(padding)
end

---@param layout lc.ui.Renderer
function Lines:draw(layout, opts)
    local options = Opts(self._.opts):merge(opts)
    local lines = self:contents()

    local padding = options:get_padding()

    local leftpad = self:get_leftpad(layout, options:get())
    options:set({ padding = { left = leftpad } })

    local toppad = padding and padding.top
    if toppad then
        lines = vim.list_extend(create_pad(toppad), lines)
    end

    local botpad = padding and padding.bot
    if botpad then
        lines = vim.list_extend(lines, create_pad(botpad))
    end

    for _, line in pairs(lines) do
        line:draw(layout, options:get())
    end
end

function Lines:append(content, highlight)
    if type(content) == "table" and O.is_instance(content, Lines) then
        local lines = content:contents()

        for i, line in ipairs(lines) do
            Lines.super.append(self, line)
            if i ~= #lines then
                self:endl()
            end
        end
    else
        Lines.super.append(self, content, highlight)
    end

    return self
end

function Lines:clear()
    Lines.super.clear(self)
    self._.lines = {}

    return self
end

function Lines:insert(item) --
    if not vim.tbl_isempty(Lines.super.contents(self)) then
        self:endl()
    end
    table.insert(self._.lines, item)

    return self
end

function Lines:replace(lines)
    self:clear()
    self._.lines = lines

    return self
end

function Lines:endl()
    local contents = Lines.super.contents(self)
    if not vim.tbl_isempty(contents) then
        table.insert(self._.lines, Line(contents))
    else
        table.insert(self._.lines, Line())
    end
    Lines.super.clear(self)

    return self
end

function Lines:init(lines, opts)
    local options = vim.tbl_deep_extend("force", {
        padding = {},
    }, opts or {})
    Lines.super.init(self, {}, options)

    self._.lines = lines or {}
end

---@type fun(lines?: lc.ui.Line[], opts?: lc.ui.opts): lc.ui.Lines
local LeetLines = Lines

return LeetLines
