local utils = require("leetcode.utils")

local Pre = require("leetcode-ui.group.pre")
local Input = require("leetcode-ui.group.pre.input")
local Stdout = require("leetcode-ui.group.pre.stdout")
local Group = require("leetcode-ui.group")
local Line = require("leetcode-ui.line")

local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@alias case_body { input: string[], raw_input: string, output: string, expected: string, std_output: string }

---@class lc.ui.Case : lc.ui.Group
---@field pre lc.ui.Lines
---@field stdout lc.ui.Lines
---@field passed boolean
---@field index integer
---@field body case_body
---@field question lc.ui.Question
local Case = Group:extend("LeetCase")

---@private
---@param input string[]
function Case:input(input)
    input = vim.tbl_map(utils.norm_ins, input)
    return Input("Input", input, self.question.q.meta_data.params)
end

---@private
---@param output string
---@param expected string
function Case:output(output, expected)
    local key = t("Output")

    local title = Line():append(key, "leetcode_normal")
    local pre = Pre(title, Line():append(utils.norm_ins(output)))

    return pre
end

---@private
---@param expected string
---@param output string
function Case:expected(expected, output)
    local key = t("Expected")
    local title = Line():append(key, "leetcode_normal")

    local pre = Pre(title, Line():append(utils.norm_ins(expected)))

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
