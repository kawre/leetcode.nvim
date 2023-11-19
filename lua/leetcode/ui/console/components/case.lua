local log = require("leetcode.logger")
local t = require("leetcode.translator")

local Pre = require("leetcode.ui.console.components.pre")
local Stdout = require("leetcode.ui.console.components.stdout")
local Group = require("leetcode-ui.component.group")

local NuiLine = require("nui.line")

---@alias case_body { input: string, raw_input: string, output: string, expected: string, std_output: string }

---@class lc.Result.Case : lc-ui.Group
---@field pre lc-ui.Text
---@field stdout lc-ui.Text
---@field passed boolean
---@field index integer
---@field body case_body
local Case = {}
Case.__index = Case
setmetatable(Case, Group)

local function get_pad(key, max_len) return (" "):rep(max_len + 1 - vim.api.nvim_strwidth(key)) end

---@private
---@param input string
---@return NuiLine
function Case:input(input)
    local key = t("Input")

    local line = NuiLine()
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

    local line = NuiLine()
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

    local line = NuiLine()
    line:append(("%s:%s"):format(key, get_pad(key, self.max_len)))
    line:append(expected, "leetcode_alt")

    return line
end

---@param body case_body
---@param passed boolean
---
---@return lc.Result.Case
function Case:init(body, passed)
    local group = Group:init({}, { spacing = 1 })
    self = setmetatable(group, self)

    self.body = body

    self.max_len = 0
    for _, key in ipairs({ "Input", "Output", "Expected" }) do
        self.max_len = math.max(self.max_len, vim.api.nvim_strwidth(t(key)))
    end

    local tbl = {}
    table.insert(tbl, self:input(body.input))
    table.insert(tbl, self:output(body.output, body.expected))
    table.insert(tbl, self:expected(body.expected, body.output))

    local pre = Pre:init(nil, tbl)
    self:append(pre)

    local stdout = Stdout:init(body.std_output)
    if stdout then self:append(stdout) end

    self.passed = passed

    return self
end

return Case
