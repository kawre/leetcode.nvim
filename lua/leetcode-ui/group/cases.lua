local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")
local Case = require("leetcode-ui.group.case")

local log = require("leetcode.logger")

---@class lc.Cases : lc-ui.Group
---@field cases table<integer, lc.Result.Case>
---@field idx integer
---@field console lc.ui.Console
local Cases = Group:extend("LeetCases")

function Cases:make_nav()
    local nav = Lines({}, { padding = { top = 1 } })

    for i, case in ipairs(self.cases) do
        self.console.result:map(
            "n",
            tostring(i),
            function() self:change(i) end,
            { clearable = true }
        )

        local hl = "leetcode_case_"
            .. ("%s%s"):format(self.idx == i and "focus_" or "", case.passed and "ok" or "err")
        local msg = (" Case (%d) "):format(i)

        nav:append(msg, hl)
        if i ~= #self.cases then nav:append(" ") end
    end

    return nav
end

function Cases:curr() return self.cases[self.idx] end

function Cases:draw(layout)
    self:clear()

    self:insert(self:make_nav())
    self:insert(self:curr())

    Cases.super.draw(self, layout)
end

---@param idx integer
function Cases:change(idx)
    if not self.cases[idx] or idx == self.idx then return end

    self.idx = idx
    self.console.result:draw()
end

---@param item lc.runtime
---@param parent lc.ui.Console
---@return lc.Cases
function Cases:init(item, parent)
    Cases.super.init(self, {}, { spacing = 1 })

    self.cases = {}
    self.console = parent

    for i = 1, item.total_testcases do
        self.cases[i] = Case({
            input = self.console.testcase.testcases[i],
            output = item.code_answer[i],
            expected = item.expected_code_answer[i],
            std_output = item.std_output_list[i],
        }, item.compare_result:sub(i, i) == "1")
    end

    self:change(1)
end

---@type fun(item: lc.runtime, parent: lc.ui.Console): lc.Cases
local LeetCases = Cases

return LeetCases
