local Pre = require("leetcode-ui.lines.pre")
local t = require("leetcode.translator")
local Line = require("leetcode-ui.line")
local Lines = require("leetcode-ui.lines")

---@class lc.Stdout : lc.Result.Pre
local Stdout = Pre:extend("LeetStdout")

---@param output string
---
---@return lc-ui.Lines | nil
function Stdout:init(output)
    local output_list = vim.split(output or "", "\n", { trimempty = true })
    if vim.tbl_isempty(output_list) then
        Stdout.super.init(self)
        self:clear()
        return
    end

    local lines = Lines()
    for i = 1, #output_list, 1 do
        lines:append(output_list[i]):endl()
    end

    local title = Line():append((" %s"):format(t("Stdout")), "leetcode_alt")
    Stdout.super.init(self, title, lines)
end

---@alias lc.Stdout.constructor fun(output: string): lc.Stdout
---@type lc.Stdout.constructor
local LeetStdout = Stdout

return LeetStdout
