local log = require("leetcode.logger")
local config = require("leetcode.config")
local ConsolePopup = require("leetcode-ui.popup.console")
local t = require("leetcode.translator")

---@class lc.ui.Console.TestcasePopup : lc.ui.Console.Popup
---@field testcases table<string[]>
---@field extmarks integer[]
local Testcase = ConsolePopup:extend("LeetTestcasePopup")

function Testcase:content()
    self.testcases = {}

    local tbl = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local str = table.concat(tbl, "\n")

    local testcases = {}
    for tcase in vim.gsplit(str, "\n\n") do
        local s = vim.split(tcase, "\n")

        table.insert(self.testcases, s)
        testcases = vim.list_extend(testcases, s)
    end

    return testcases
end

function Testcase:populate()
    local tbl = {}
    for i, case in ipairs(self.console.question.q.testcase_list) do
        if i ~= 1 then table.insert(tbl, "") end

        table.insert(self.testcases, vim.split(case, "\n"))

        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(tbl, s)
        end
    end

    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, tbl)

    return self:draw_extmarks()
end

function Testcase:clear_extmarks()
    if not config.user.console.testcase.virt_text then return end
    local ns = vim.api.nvim_create_namespace("leetcode_extmarks")

    self.extmarks = vim.tbl_filter(
        function(extmark) return not vim.api.nvim_buf_del_extmark(self.bufnr, ns, extmark) end,
        self.extmarks
    )
end

---@param line integer
---@param col integer
---@param opts? table<string, table>
function Testcase:add_extmark(line, col, opts)
    local ns = vim.api.nvim_create_namespace("leetcode_extmarks")

    table.insert(self.extmarks, vim.api.nvim_buf_set_extmark(self.bufnr, ns, line, col, opts or {}))
end

function Testcase:draw_extmarks()
    if not config.user.console.testcase.virt_text then return end

    self:clear_extmarks()
    local bufnr = self.bufnr

    local md = self.console.question.q.meta_data
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if not md.params then return end

    local j = 1
    local function get_param(idx)
        return {
            { (" "):rep(2) },
            { "", "Operator" },
            { " " },
            { md.params[idx].name, "Comment" },
            { " " },
            { md.params[idx].type, "Type" },
        }
    end

    local invalid = false

    for i, line in ipairs(lines) do
        pcall(function()
            if lines[i - 1] == "" and lines[i] == "" then invalid = true end
        end)

        if line ~= "" then
            local ok, text = pcall(get_param, j)
            if not ok or invalid then
                text = { { (" "):rep(2) }, { (" %s"):format(t("invalid")), "leetcode_error" } }
            end

            self:add_extmark(i - 1, -1, { virt_text = text })
            j = j + 1
        else
            j = 1
        end
    end

    return self
end

function Testcase:reset()
    self:populate()
    log.info("Test cases have been reset")
end

function Testcase:append(input)
    local s = vim.split(input, "\n", { trimempty = true })

    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true)
    if #lines > 1 or (#lines == 1 and lines[1] ~= "") then
        vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { "", unpack(s) })
    else
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, s)
    end

    self:draw_extmarks()
end

function Testcase:autocmds()
    self:on(
        { "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT" },
        function() self:draw_extmarks() end
    )
end

function Testcase:mount()
    Testcase.super.mount(self)

    self.testcases = {}
    self.extmarks = {}

    self:autocmds()
    self:populate()
end

---@param parent lc.ui.Console
function Testcase:init(parent)
    local keys = require("leetcode.config").user.keys

    Testcase.super.init(self, parent, {
        enter = true,
        border = {
            text = {
                top = (" (%s) %s "):format(keys.focus_testcases, t("Testcases")),
                top_align = "center",
                bottom = (" (%s) %s "):format(keys.reset_testcases, t("Reset")),
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
            wrap = true,
        },
    })

    self.testcases = {}
    self.extmarks = {}

    self:populate()
end

---@type fun(parent: lc.ui.Console): lc.ui.Console.TestcasePopup
local LeetTestcasePopup = Testcase

return LeetTestcasePopup
