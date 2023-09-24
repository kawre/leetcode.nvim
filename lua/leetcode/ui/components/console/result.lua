local log = require("leetcode.logger")

local Case = require("leetcode.ui.components.console.components.case")
local Group = require("leetcode-ui.component.group")
local Pre = require("leetcode.ui.components.console.components.pre")
local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")

local NuiLine = require("nui.line")
local NuiPopup = require("nui.popup")

---@class lc.Result
---@field popup NuiPopup
---@field layout lc-ui.Layout
---@field parent lc.Console
local result = {}
result.__index = result

---@private
---
---@param item runtime
function result:handle_runtime(item) -- status code = 10
    local header = NuiLine()

    if item.correct_answer then
        header:append("Accepted", "DiagnosticOk")
    else
        header:append("Wrong Answer", "DiagnosticError")
    end

    header:append(" | ")
    header:append("Runtime: " .. item.status_runtime, "Comment")

    self.layout:append(Text:init({ lines = { header, NuiLine() } }))

    local group = Group:init({ opts = { spacing = 1 } })
    for i, answer in ipairs(item.code_answer) do
        local text =
            Case:init(i, self.parent.testcase.testcases[i], answer, item.expected_code_answer[i])
        group:append(text)
    end

    self.layout:append(group)
end

---@private
---
---@param item runtime_error
function result:handle_runtime_error(item) -- status code = 15
    local header = NuiLine()
    header:append("Invalid Testcase", "DiagnosticError")

    local t = {}
    for line in vim.gsplit(item.full_runtime_error, "\n") do
        table.insert(t, NuiLine():append(line, "DiagnosticError"))
    end

    local pre = Pre:init(header, t)
    self.layout:append(pre)
end

---@private
---
---@param item compile_error
function result:handle_compile_error(item) -- status code = 20
    local header = NuiLine()
    header:append(item.status_msg, "DiagnosticError")

    local t = {}
    for line in vim.gsplit(item.full_compile_error, "\n") do
        table.insert(t, NuiLine():append(line, "DiagnosticError"))
    end

    self.layout:append(Pre:init(header, t))
end

---@param item interpreter_response
function result:handle(item)
    self.layout:clear()
    local status_code = item.status_code

    self.popup.border:set_highlight(item.correct_answer and "DiagnosticOk" or "DiagnosticError")

    local handlers = {
        -- runtime
        [10] = function()
            self:handle_runtime(item --[[@as runtime]])
        end,
        [15] = function()
            self:handle_runtime_error(item --[[@as runtime_error]])
        end,

        -- compiler
        [20] = function()
            self:handle_compile_error(item --[[@as compile_error]])
        end,

        -- unknown
        ["unknown"] = function() log.error("unknown runner status code: " .. item.status_code) end,
    }

    handlers[status_code or "unknown"]()

    self:draw()
end

function result:clear()
    self.popup.border:set_highlight("FloatBorder")
    vim.api.nvim_buf_set_lines(self.popup.bufnr, 0, -1, false, {})
end

function result:draw()
    -- vim.api.nvim_buf_set_option(self.popup.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.popup.bufnr, 0, -1, false, {})
    self.layout:draw(self.popup)
    -- vim.api.nvim_buf_set_option(self.popup.bufnr, "modifiable", false)
end

---@param parent lc.Console
---
---@return lc.Result
function result:init(parent)
    local t = {}
    for _, case in ipairs(parent.parent.q.testcase_list) do
        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(t, s)
        end
    end

    local popup = NuiPopup({
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
                top = " Result ",
                top_align = "center",
                bottom = " (R) Run | (S) Submit ",
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = true,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
        },
    })

    local obj = setmetatable({
        popup = popup,
        layout = Layout:init({ contents = {} }),
        parent = parent,
    }, self)

    return obj
end

return result
