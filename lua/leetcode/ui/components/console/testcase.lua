local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local log = require("leetcode.logger")
local NuiPopup = require("nui.popup")

---@class lc.Testcase
---@field popup NuiPopup
---@field testcases string[]
local testcase = {}
testcase.__index = testcase

function testcase:content()
    self.testcases = {}

    local t = vim.api.nvim_buf_get_lines(self.popup.bufnr, 0, -1, false)
    local str = table.concat(t, "\n")

    local testcases = {}
    for tcase in vim.gsplit(str, "\n\n") do
        local case = tcase:gsub("\n", " ")
        table.insert(self.testcases, case)
        testcases = vim.list_extend(testcases, vim.split(tcase, "\n"))
    end

    return testcases
end

---@param parent lc.Console
function testcase:init(parent)
    local popup = NuiPopup({
        enter = true,
        focusable = true,
        border = {
            padding = {
                top = 1,
                bottom = 1,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = " Console | (q) Hide ",
                top_align = "center",
                bottom = " Testcase ",
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
        },
    })

    local obj = setmetatable({
        popup = popup,
        testcases = {},
    }, self)

    local t = {}
    for i, case in ipairs(parent.parent.q.testcase_list) do
        if i ~= 1 then table.insert(t, "") end

        table.insert(obj.testcases, case:gsub("\n", " ")[1])

        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(t, s)
        end
    end

    vim.api.nvim_buf_set_lines(obj.popup.bufnr, 0, -1, false, t)

    return obj
end

return testcase
