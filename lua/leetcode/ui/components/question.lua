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
    local s = vim.split(question.content, "\n\n<p>&nbsp;</p>\n")
    local lines = {}

    vim.list_extend(lines, M.description(s[1]))
    vim.list_extend(lines, M.examples(s[2]))
    -- local cons = parser.parse(s[3])
    -- local foll = parser.parse(s[4])

    return lines
end

---@param html string
---
---@return NuiLine[]
function M.description(html)
    local lines = {}

    for s in vim.gsplit(html, "\n\n") do
        table.insert(lines, Line(parser.parse(s:gsub("s(?![^<>]*>)", "&nbsp;"))))
    end

    return lines
end

---@param html string
---
---@return NuiLine[]
function M.examples(html)
    local lines = {}

    for s in vim.gsplit(html, "\n\n") do
        table.insert(lines, Line(parser.parse(s:gsub("s(?![^<>]*>)", "&nbsp;"))))
    end

    return lines
end

---@param html string
---
---@return NuiLine[]
function M.constrains(html) end

---@param html string
---
---@return NuiLine[]
function M.follow_up(html) end

return M
