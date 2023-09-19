local log = require("leetcode.logger")

local Text = require("nui.text")
local Line = require("nui.line")
local Layout = require("nui.layout")
local parser = require("leetcode.parser")

local utils = require("leetcode.utils")

---@class lc.Ui.Components.Problem
local M = {}

---@param title any
function M.title(title)
    local line = Line()

    line:append(title.questionFrontendId .. ". " .. title.title)

    return line
end

---@param title_slug string
function M.link(title_slug)
    local line = Line()

    line:append("https://leetcode.com/problems/" .. title_slug .. "/", "Comment")
    line:append("")

    return line
end

---@param title any
function M.stats(title)
    local line = Line()

    line:append(
        title.difficulty,
        title.difficulty == "Easy" and "DiagnosticOk"
            or title.difficulty == "Medium" and "DiagnosticWarn"
            or "DiagnosticError"
    )
    line:append(" | ")
    line:append(title.likes .. "  ", "Comment")
    line:append(title.dislikes .. "  ", "Comment")

    return line
end

---@param question any
---
---@return NuiLine[]
function M.content(question)
    local s = vim.split(question.content, "\n\n<p>&nbsp;</p>\n", { trimempty = true })

    local desc = parser.parse(s[1])
    local exam = parser.parse(s[2])
    local cons = parser.parse(s[3])
    local foll = parser.parse(s[4])

    return { desc, exam, cons, foll }
end

---@param html string
function M.description(html) return parser.parse(html) end

---@param examples string
function M.examples(examples) end

---@param constrains string
function M.constrains(constrains) end

---@param follow_up string
function M.follow_up(follow_up) end

return M
