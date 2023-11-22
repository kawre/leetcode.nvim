local Pre = require("leetcode.ui.console.components.pre")
local t = require("leetcode.translator")
local Line = require("leetcode-ui.component.line")

---@class lc.Stdout : lc.Result.Pre
local Stdout = Pre:extend("LeetStdout")

---@param output string
---
---@return lc-ui.Lines | nil
function Stdout:init(output)
    local output_list = vim.split(output or "", "\n", { trimempty = true })
    if vim.tbl_isempty(output_list) then
        Stdout.super.init(self, nil, {})
        return
    end

    local tbl = {}
    for i = 1, #output_list, 1 do
        local line = Line()
        line:append(output_list[i])
        table.insert(tbl, line)
    end

    local title = Line():append((" %s"):format(t("Stdout")), "leetcode_alt")
    Stdout.super.init(self, title, tbl)
end

---@alias lc.Stdout.constructor fun(output: string): lc.Stdout
---@type lc.Stdout.constructor
local LeetStdout = Stdout

return LeetStdout
