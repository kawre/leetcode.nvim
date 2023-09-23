local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local NuiPopup = require("nui.popup")

---@class lc.Testcase
---@field popup NuiPopup
local result = {}
result.__index = result

---@param parent lc.Console
function result:init(parent)
    local t = {}
    for _, case in ipairs(parent.parent.testcases) do
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
                top = " (r) Result ",
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
            -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
        },
    })

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, t)

    local obj = setmetatable({
        popup = popup,
    }, self)

    return obj
end

return result
