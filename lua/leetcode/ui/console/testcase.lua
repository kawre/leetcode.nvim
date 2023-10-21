local log = require("leetcode.logger")
local config = require("leetcode.config")
local NuiPopup = require("nui.popup")
local console_popup = require("leetcode.ui.console.popup")

---@class lc.Testcase: lc.Console.Popup
---@field testcases string[]
---@field extmarks integer[]
local testcase = {}
testcase.__index = testcase
setmetatable(testcase, console_popup)

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

function testcase:draw()
    local t = {}
    for i, case in ipairs(self.parent.parent.q.testcase_list) do
        if i ~= 1 then table.insert(t, "") end

        table.insert(self.testcases, case:gsub("\n", " ")[1])

        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(t, s)
        end
    end

    vim.api.nvim_buf_set_lines(self.popup.bufnr, 0, -1, false, t)

    self:draw_extmarks()
    return self
end

function testcase:clear_extmarks()
    if not config.user.console.testcase.virt_text then return end
    local ns = vim.api.nvim_create_namespace("leetcode_extmarks")

    self.extmarks = vim.tbl_filter(
        function(extmark) return not vim.api.nvim_buf_del_extmark(self.popup.bufnr, ns, extmark) end,
        self.extmarks
    )
end

---@param line integer
---@param col integer
---@param opts? table<string, table>
function testcase:add_extmark(line, col, opts)
    local ns = vim.api.nvim_create_namespace("leetcode_extmarks")

    table.insert(
        self.extmarks,
        vim.api.nvim_buf_set_extmark(self.popup.bufnr, ns, line, col, opts or {})
    )
end

function testcase:draw_extmarks()
    if not config.user.console.testcase.virt_text then return end

    self:clear_extmarks()
    local bufnr = self.popup.bufnr

    local md = self.parent.parent.q.meta_data
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if not md.params then return end

    local function get_param(idx)
        return {
            { " " },
            { "", "Operator" },
            { " " },
            { md.params[idx].name, "Comment" },
            { " " },
            { md.params[idx].type, "Type" },
        }
    end

    local j = 1
    local invalid = false

    for i, line in ipairs(lines) do
        pcall(function()
            if lines[i - 1] == "" and lines[i] == "" then invalid = true end
        end)

        if line ~= "" then
            local ok, text = pcall(get_param, j)
            if not ok or invalid then text = { { " " }, { " invalid", "leetcode_error" } } end

            self:add_extmark(i - 1, -1, { virt_text = text })
            j = j + 1
        else
            j = 1
        end
    end
end

function testcase:reset()
    self:draw()
    log.info("Test cases have been reset")
end

function testcase:autocmds()
    self.popup:on(
        { "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT" },
        function() self:draw_extmarks() end
    )
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
                top = " Testcases ",
                top_align = "center",
                bottom = " (r) Reset ",
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

    self = setmetatable({
        popup = popup,
        testcases = {},
        extmarks = {},
        parent = parent,
    }, self)

    self:autocmds()
    return self:draw()
end

return testcase
