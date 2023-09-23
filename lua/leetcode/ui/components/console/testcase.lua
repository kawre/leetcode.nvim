local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local NuiPopup = require("nui.popup")

---@class lc.Testcase
---@field popup NuiPopup
local testcase = {}
testcase.__index = testcase

---@param parent lc.Console
function testcase:init(parent)
    local t = {}
    for _, case in ipairs(parent.parent.testcases) do
        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(t, s)
        end
    end

    local popup = NuiPopup({
        -- position = "50%",
        -- size = config.user.console.size,
        -- enter = true,
        -- focusable = true,
        -- zindex = 50,
        -- relative = "editor",
        border = {
            padding = {
                top = 1,
                bottom = 1,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = " Console | (q) hide ",
                top_align = "center",
                bottom = " (t) Testcase ",
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

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, t)

    local obj = setmetatable({
        popup = popup,
    }, self)

    return obj
end

return testcase
