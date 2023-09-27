local log = require("leetcode.logger")
local config = require("leetcode.config")
local Stdout = require("leetcode.ui.console.components.stdout")
local console_popup = require("leetcode.ui.console.popup")

local Case = require("leetcode.ui.console.components.case")
local Group = require("leetcode-ui.component.group")
local Pre = require("leetcode.ui.console.components.pre")
local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")

local NuiLine = require("nui.line")
local NuiPopup = require("nui.popup")

---@class lc.Result: lc.Console.Popup
---@field layout lc-ui.Layout
local result = {}
result.__index = result
setmetatable(result, console_popup)

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

        local stdout = Stdout:init(i, item)
        if stdout then group:append(stdout) end
    end

    self.layout:append(group)
end

---@private
---
---@param item limit_exceeded_error
function result:handle_limit_exceeded(item) -- status code = 14
    local header = NuiLine()
    header:append(item.status_msg, "DiagnosticError")

    self.layout:append(Text:init({ lines = { header, NuiLine() } }))
    local stdout = Stdout:init(1, item)
    if stdout then self.layout:append(stdout) end
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

function result:handle_internal_error(item) -- status code = 16
    log.inspect(item)
    local header = NuiLine()
    header:append(item.status_msg, "DiagnosticError")

    local text = Text:init({ lines = { header } })
    self.layout:append(text)
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

    log.debug(status_code)
    self.popup.border:set_highlight(item.correct_answer and "DiagnosticOk" or "DiagnosticError")

    local handlers = {
        -- runtime
        [10] = function()
            self:handle_runtime(item --[[@as runtime]])
        end,

        -- time limit
        [13] = function()
            self:handle_limit_exceeded(item --[[@as limit_exceeded_error]])
        end,
        [14] = function()
            self:handle_limit_exceeded(item --[[@as limit_exceeded_error]])
        end,

        -- runtime error
        [15] = function()
            self:handle_runtime_error(item --[[@as runtime_error]])
        end,

        -- internal error
        [16] = function()
            self:handle_internal_error(item --[[@as internal_error]])
        end,

        -- compiler
        [20] = function()
            self:handle_compile_error(item --[[@as compile_error]])
        end,

        -- unknown
        ["unknown"] = function() log.error("unknown runner status code: " .. item.status_code) end,
    }

    if not handlers[status_code] then log.debug(status_code) end
    (handlers[status_code] or handlers["unknown"])()

    self:draw()
end

function result:clear()
    self.layout:clear()
    self.popup.border:set_highlight("FloatBorder")

    -- local bufnr = self.popup.bufnr
    -- local modi = vim.api.nvim_buf_get_option(bufnr, "modifiable")
    -- if not modi then vim.api.nvim_buf_set_option(bufnr, "modifiable", true) end
    -- vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    -- if not modi then vim.api.nvim_buf_set_option(bufnr, "modifiable", false) end
end

function result:draw() self.layout:draw(self.popup) end

-- function result:redraw() self.layout:draw() end

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
            modifiable = false,
            readonly = true,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
        },
    })

    local obj = setmetatable({
        popup = popup,
        layout = Layout:init({
            winid = popup.winid,
            bufnr = popup.bufnr,
        }),
        parent = parent,
    }, self)

    return obj
end

return result
