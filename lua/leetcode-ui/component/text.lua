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

function Lines:contents()
    log.debug("get contents: " .. self.class.name)
    local contents = vim.deepcopy(self.lines)
    if not vim.tbl_isempty(self._texts) then table.insert(contents, vim.deepcopy(self)) end
    return contents
end

---@param layout lc-ui.Layout
function Lines:draw(layout)
    log.debug("")
    log.debug("[DRAW START] " .. self.class.name)
    local lines = self:contents()

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
        new_line:render(layout.bufnr, -1, line_idx, line_idx)
        --
        -- if self.opts.on_press then
        --     layout:set_on_press(line_idx, self.opts.on_press, self.opts.sc)
        -- end
    end

    log.debug("[DRAW END] " .. self.class.name)
    log.debug("")
end

function Lines:clear()
    log.debug("clear: " .. self.class.name)
    self:endl()
    self.lines = {}
end

function Lines:append(content, highlight)
    local ok, contents = pcall(Lines.contents, content)
    if ok then
        for _, line in ipairs(contents) do
            Lines.super.append(self, line, highlight or self.opts.hl)
            self:endl()
        end
    else
        Lines.super.append(self, content, highlight or self.opts.hl)
    end

    return self
end

function Lines:endl()
    if not vim.tbl_isempty(self._texts) then
        table.insert(self.lines, vim.deepcopy(self))
        self._texts = {}
    end

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
    Lines.super.init(self)

    self.opts = opts or {}
    self.lines = {}
    self.__is_lines = true
end

---@type fun(opts?: lc-ui.Component.opts): lc-ui.Text
local LeetLines = Lines

return LeetLines
