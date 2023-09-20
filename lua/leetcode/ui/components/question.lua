local log = require("leetcode.logger")
local gql = require("leetcode.graphql")

local Line = require("nui.line")
local Split = require("nui.split")
local parser = require("leetcode.parser")

---@class lc.Ui.Components.Problem
local M = {}

---@type integer, NuiSplit
local curr_line, split

---Increment current line
---
---@return nil
local function inc_line() curr_line = curr_line + 1 end

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

---@param content string
---
---@return nil
function M.content(content)
    local s = vim.gsplit(content, "\n", {})

    for l in s do
        parser.parse(l):render(split.bufnr, -1, curr_line)
        inc_line()
    end
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
function M.constrains(html)
    local lines = {}

    for s in vim.gsplit(html, "\n\n") do
        log.info(s)
        table.insert(lines, Line(parser.parse(s:gsub("s(?![^<>]*>)", "&nbsp;"))))
    end

    return lines
end

---@param html string
---
---@return NuiLine[]
function M.follow_up(html) end

---Render question split
---
---@param question lc.Problem
---
---@return nil
function M.open(question)
    curr_line = 1

    split = Split({
        relative = "editor",
        position = "left",
        size = "40%",
        buf_options = {
            modifiable = true,
            readonly = false,
            filetype = "leetcode.nvim",
            swapfile = false,
            buftype = "nofile",
            buflisted = false,
        },
        win_options = {
            -- winblend = 10,
            -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            foldcolumn = "1",
            wrap = true,
            number = false,
            signcolumn = "no",
        },
        enter = true,
        focusable = true,
    })
    split:mount()

    vim.api.nvim_buf_set_name(split.bufnr, "LeetCode")

    local title = gql.question.title(question.title_slug)
    local content = gql.question.content(question.title_slug).content

    M.link(question.title_slug):render(split.bufnr, -1, curr_line)
    inc_line()

    M.title(title):render(split.bufnr, -1, curr_line)
    inc_line()

    M.stats(title):render(split.bufnr, -1, curr_line)
    inc_line()

    M.content(content)
end

return M
