local NuiLine = require("nui.line")
local NuiText = require("nui.text")

---@class lc.ui.Line : NuiLine
local Line = NuiLine:extend("LeetLine")

---@param layout lc-ui.Renderer
---@param opts lc-ui.Layout.opts
function Line:draw(layout, opts)
    local texts = vim.deepcopy(self._texts)

    opts = opts or {}
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

function Line:append(content, highlight)
    Line.super.append(self, content, highlight)
    return self
end

---@param texts? NuiText[]
function Line:init(texts) --
    Line.super.init(self, texts)
end

---@type fun(texts?: NuiText[]): lc.ui.Line
local LeetLine = Line

return LeetLine
