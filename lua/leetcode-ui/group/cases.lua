local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")
local Case = require("leetcode-ui.group.case")

local log = require("leetcode.logger")

---@class lc.ui.Cases : lc.ui.Group
---@field cases table<integer, lc.ui.Case>
---@field idx integer
---@field console lc.ui.Console
local Cases = Group:extend("LeetCases")

function Cases:nav_case_hl(case, i) --
    return "leetcode_case_" --
        .. (self.idx == i and "focus_" or "")
        .. (case.passed and "ok" or "err")
end

function Cases:make_nav()
    local nav = Lines({}, { padding = { top = 1 } })

    for i, case in ipairs(self.cases) do
        self.console.result:map("n", i, function()
            self:change(i)
        end, { clearable = true })

        local hl = self:nav_case_hl(case, i)
        local msg = (" Case (%d) "):format(i)

        nav:append(msg, hl)
        if i ~= #self.cases then
            nav:append(" ")
        end
    end

    return nav
end

function Cases:draw(layout)
    self:replace({
        self:make_nav(),
        self.cases[self.idx],
    })

    Cases.super.draw(self, layout)
end

---@param idx integer
function Cases:change(idx)
    if not self.cases[idx] or idx == self.idx then
        return
    end

    self.idx = idx
    self.console.result:draw()
end

---@param item lc.runtime
---@param parent lc.ui.Console
---@return lc.ui.Cases
function Cases:init(item, parent)
    Cases.super.init(self, {}, { spacing = 1 })

    self.cases = {}
    self.console = parent

    local total = item.total_testcases ~= vim.NIL and item.total_testcases or 0
    local testcases = parent.testcase:by_id(item.submission_id)

    for i = 1, total do
        self.cases[i] = Case({
            input = testcases[i],
            output = item.code_answer[i],
            expected = item.expected_code_answer[i],
            std_output = item.std_output_list[i],
        }, item.compare_result:sub(i, i) == "1", parent.question)
    end

    self:change(1)
end

---@type fun(item: lc.runtime, parent: lc.ui.Console): lc.ui.Cases
local LeetCases = Cases

return LeetCases
