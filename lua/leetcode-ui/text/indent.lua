local Text = require("nui.text")

---@class lc.ui.Indent : lc.ui.Line
local Indent = Text:extend("LeetIndent")

function Indent:init(i, char, hl) --
    local text = ("\t"):rep(i or 0) .. (char or "")
    Indent.super.init(self, text, hl)
end

---@type fun(c: integer, text: string, hl: string): lc.ui.Indent
local LeetIndent = Indent

return LeetIndent
