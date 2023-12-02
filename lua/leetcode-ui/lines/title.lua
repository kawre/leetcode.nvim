local Lines = require("leetcode-ui.lines")
local t = require("leetcode.translator")

---@class lc-menu.Title : lc.ui.Lines
---@field text lc.ui.Lines
local Title = Lines:extend("LeetMenuTitle")

---@param history string[]
---@param str string
---@param opts? any
function Title:init(history, str, opts)
    history = vim.tbl_map(t, history)
    str = t(str)

    opts = vim.tbl_deep_extend("force", {
        padding = {
            top = 1,
        },
    }, opts or {})

    Title.super.init(self, {}, opts)

    for _, hist in ipairs(history) do
        self:append(hist, "leetcode_alt")
        self:append("  ", "leetcode_list")
    end
    self:append(str, "Function")
end

---@type fun(history: string[], str: string, opts?: any): lc-menu.Title
local LeetMenuTitle = Title

return LeetMenuTitle
