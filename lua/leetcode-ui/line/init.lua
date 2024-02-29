local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local Opts = require("leetcode-ui.opts")
local utils = require("leetcode-ui.utils")
local log = require("leetcode.logger")

---@class lc.ui.Line : NuiLine
local Line = NuiLine:extend("LeetLine")

function Line:contents()
    return self._texts
end

function Line:longest()
    if self.class.name == "LeetLine" then
        return vim.api.nvim_strwidth(self:content())
    end

    local max_len = 0
    for _, item in pairs(self:contents()) do
        max_len = math.max(Line.longest(item), max_len)
    end

    return max_len
end

---@param layout lc.ui.Renderer
---@param opts lc.ui.opts
function Line:draw(layout, opts)
    local texts = utils.shallowcopy(self:contents())

    local options = Opts(self._.opts):merge(opts)
    local pad = options:get_padding()

    if pad then
        if pad.left then
            table.insert(texts, 1, NuiText((" "):rep(pad.left)))
        elseif pad.right then
            table.insert(texts, NuiText((" "):rep(pad.right)))
        end
    end

    local line_idx = layout:get_line_idx(1)
    NuiLine(texts):render(layout.bufnr, -1, line_idx, line_idx)
end

function Line:clear() --
    self._texts = {}

    return self
end

function Line:replace(texts)
    self._texts = texts

    return self
end

function Line:append(content, highlight)
    Line.super.append(self, content, highlight or self._.opts.hl)

    return self
end

---@param opts? lc.ui.opts
function Line:set_opts(opts) --
    self._.opts = vim.tbl_deep_extend("force", self._.opts or {}, opts or {})
end

---@param texts? NuiText[]
---@param opts? lc.ui.opts
function Line:init(texts, opts) --
    self._ = {}
    self:set_opts(opts)

    Line.super.init(self, texts)
end

---@type fun(texts?: NuiText[], opts?: lc.ui.opts): lc.ui.Line
local LeetLine = Line

return LeetLine
