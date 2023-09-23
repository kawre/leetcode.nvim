local log = require("leetcode.logger")

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

---@param item lc.Interpreter.Response
function result:handle(item)
    local status_code = item.status_code
    local text = Text:init({})

    text:append(item.status_msg, "DiagnosticError")
    text:append("")

    local lines = {}
    if status_code == 20 then
        lines = vim.split(item.full_compile_error, "\n")
        for _, line in ipairs(lines) do
            text:append("\t▎\t" .. line, "DiagnosticError")
        end
    end

    self.layout:clear()
    self.layout = self.layout:append(text)
    self:draw()
end

function result:draw()
    -- vim.api.nvim_buf_set_option(self.popup.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.popup.bufnr, 0, -1, false, {})
    self.layout:draw(self.popup)
    -- vim.api.nvim_buf_set_option(self.popup.bufnr, "modifiable", false)
end

---@param parent lc.Console
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

    obj.popup:map("n", "R", function() parent.parent:run() end)
    obj.popup:map("n", "q", function() parent:hide() end)

    return obj
end

return result
