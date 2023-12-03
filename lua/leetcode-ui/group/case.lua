local log = require("leetcode.logger")
local t = require("leetcode.translator")
local utils = require("leetcode.utils")

local Pre = require("leetcode-ui.group.pre")
local Stdout = require("leetcode-ui.group.pre.stdout")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local Line = require("leetcode-ui.line")

---@alias case_body { input: string, raw_input: string, output: string, expected: string, std_output: string }

---@class lc.ui.Case : lc.ui.Group
---@field pre lc.ui.Lines
---@field stdout lc.ui.Lines
---@field passed boolean
---@field index integer
---@field body case_body
---@field question lc-ui.Question
local Case = Group:extend("LeetCase")

---@private
---@param input string
function Case:input(input)
    local key = t("Input")

    local group = Group({}, { spacing = 1 })
    local s = vim.split(input, " ")
    for i = 1, #s do
        local ok, param = pcall(function() return self.question.q.meta_data.params[i].name end)
        if ok then group:append(param .. " =", "leetcode_normal"):endl() end
        group:append(s[i]):endgrp()
    end

    local title = Line():append(key, "leetcode_normal")
    local pre = Pre(title, group)

    return pre
end

---@private
---@param output string
---@param expected string
function Case:output(output, expected)
    local key = t("Output")

    local title = Line():append(key, "leetcode_normal")
    local pre = Pre(title, Line():append(output))

    return pre
end

---@private
---@param expected string
---@param output string
function Case:expected(expected, output)
    local key = t("Expected")
    local title = Line():append(key, "leetcode_normal")

    local pre = Pre(title, Line():append(expected))

    return pre
end

---@param body case_body
---@param passed boolean
---
---@return lc.ui.Case
function Case:init(body, passed)
    Case.super.init(self, {}, { spacing = 1 })

    self.body = body
    self.question = utils.curr_question()

    self:insert(self:input(body.input))
    self:insert(self:output(body.output, body.expected))
    self:insert(self:expected(body.expected, body.output))

    local stdout = Stdout(body.std_output)
    self:insert(stdout)

    self.passed = passed
end

---@alias lc.Result.Case.constructor fun(body: case_body, passed: boolean): lc.ui.Case
---@type lc.Result.Case.constructor
local LeetCase = Case

return LeetCase
