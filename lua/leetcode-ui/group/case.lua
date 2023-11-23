local log = require("leetcode.logger")
local t = require("leetcode.translator")

local Pre = require("leetcode-ui.lines.pre")
local Stdout = require("leetcode-ui.lines.pre.stdout")
local Group = require("leetcode-ui.group")

local Line = require("leetcode-ui.line")

---@alias case_body { input: string, raw_input: string, output: string, expected: string, std_output: string }

---@class lc.Result.Case : lc-ui.Group
---@field pre lc-ui.Lines
---@field stdout lc-ui.Lines
---@field passed boolean
---@field index integer
---@field body case_body
local Case = Group:extend("LeetCase")

local function get_pad(key, max_len) return (" "):rep(max_len + 1 - vim.api.nvim_strwidth(key)) end

---@private
---@param input string
---@return NuiLine
function Case:input(input)
    local key = t("Input")

    local line = Line()
    line:append(("%s:%s"):format(key, get_pad(key, self.max_len)))
    line:append(input, "leetcode_alt")

    return line
end

---@private
---@param output string
---@param expected string
---@return NuiLine
function Case:output(output, expected)
    local key = t("Output")

    local line = Line()
    line:append(("%s:%s"):format(key, get_pad(key, self.max_len)))
    line:append(output, "leetcode_alt")

    return line
end

---@private
---@param expected string
---@param output string
---@return NuiLine
function Case:expected(expected, output)
    local key = t("Expected")

    local line = Line()
    line:append(("%s:%s"):format(key, get_pad(key, self.max_len)))
    line:append(expected, "leetcode_alt")

    return line
end

---@param body case_body
---@param passed boolean
---
---@return lc.Result.Case
function Case:init(body, passed)
    Case.super.init(self, { spacing = 1 })

    self.body = body

    self.max_len = 0
    for _, key in ipairs({ "Input", "Output", "Expected" }) do
        self.max_len = math.max(self.max_len, vim.api.nvim_strwidth(t(key)))
    end

    local tbl = {}
    table.insert(tbl, self:input(body.input))
    table.insert(tbl, self:output(body.output, body.expected))
    table.insert(tbl, self:expected(body.expected, body.output))

    local pre = Pre(nil, tbl)
    self:insert(pre)

    local stdout = Stdout(body.std_output)
    self:insert(stdout)

    self.passed = passed
end

---@alias lc.Result.Case.constructor fun(body: case_body, passed: boolean): lc.Result.Case
---@type lc.Result.Case.constructor
local LeetCase = Case

return LeetCase
