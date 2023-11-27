local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local log = require("leetcode.logger")

---@class lc.ui.Line : NuiLine
local Line = NuiLine:extend("LeetLine")

function Line:contents() return vim.deepcopy(self._texts) end

---@param layout lc-ui.Renderer
---@param opts lc-ui.Layout.opts
function Line:draw(layout, opts)
    local texts = self:contents()

    opts = vim.tbl_deep_extend("force", self._.opts, opts)
    local pad = opts.padding

    if pad then
        if pad.left then --
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

function Line:append(content, highlight)
    Line.super.append(self, content, highlight or self._.opts.hl)
    return self
end

---@param opts lc-ui.Group.opts
function Line:set_opts(opts) --
    self._.opts = vim.tbl_deep_extend("force", self._.opts or {}, opts or {})
end

---@param texts? NuiText[]
function Line:init(texts, opts) --
    self._ = {}
    self:set_opts(opts)

    Line.super.init(self, texts)
end

---@type fun(texts?: NuiText[]): lc.ui.Line
local LeetLine = Line

return LeetLine
