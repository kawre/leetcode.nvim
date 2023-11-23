local log = require("leetcode.logger")
local config = require("leetcode.config")
local ConsolePopup = require("leetcode-ui.popup.console")
local t = require("leetcode.translator")

---@class lc.ui.Console.TestcasePopup : lc.ui.Console.Popup
---@field testcases string[]
---@field extmarks integer[]
local Testcase = ConsolePopup:extend("LeetTestcasePopup")

function Testcase:content()
    self.testcases = {}

    local tbl = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local str = table.concat(tbl, "\n")

    local testcases = {}
    for tcase in vim.gsplit(str, "\n\n") do
        local case = tcase:gsub("\n", " ")
        table.insert(self.testcases, case)
        testcases = vim.list_extend(testcases, vim.split(tcase, "\n"))
    end

    return testcases
end

function Testcase:draw()
    local tbl = {}
    for i, case in ipairs(self.console.parent.q.testcase_list) do
        if i ~= 1 then table.insert(tbl, "") end

        table.insert(self.testcases, case:gsub("\n", " ")[1])

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

    local md = self.console.parent.q.meta_data
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if not md.params then return end

    local max_lens = {}
    local j, k = 1, 1
    for _, line in ipairs(lines) do
        if line == "" then k = k + 1 end
        max_lens[k] = math.max(max_lens[k] or 1, line:len() + 1)
    end

    local function get_param(idx, param_idx, len)
        return {
            { (" "):rep(max_lens[idx] - len) },
            { "", "Operator" },
            { " " },
            { md.params[param_idx].name, "Comment" },
            { " " },
            { md.params[param_idx].type, "Type" },
        }
    end

    local invalid = false
    k = 1

    for i, line in ipairs(lines) do
        pcall(function()
            if lines[i - 1] == "" and lines[i] == "" then invalid = true end
        end)

        if line ~= "" then
            local ok, text = pcall(get_param, k, j, line:len())
            if not ok or invalid then
                text = { { (" %s"):format(t("invalid")), "leetcode_error" } }
            end

            self:add_extmark(i - 1, -1, { virt_text = text })
            j = j + 1
        else
            k = k + 1
            j = 1
        end
    end

    return self
end

function Testcase:reset()
    self:draw()
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

    self:on(
        { "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT" },
        function() self:draw_extmarks() end
    )

    self:draw()
end

---@param parent lc.ui.Console
function Testcase:init(parent)
    Testcase.super.init(self, parent, {
        enter = true,
        border = {
            text = {
                top = (" (H) %s "):format(t("Testcases")),
                top_align = "center",
                bottom = (" (r) %s | (U) %s "):format(t("Reset"), t("Use Testcase")),
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
end

---@type fun(parent: lc.ui.Console): lc.ui.Console.TestcasePopup
local LeetTestcasePopup = Testcase

return LeetTestcasePopup
