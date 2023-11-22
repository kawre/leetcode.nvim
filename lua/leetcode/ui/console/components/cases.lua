local Group = require("leetcode-ui.component.group")
local Lines = require("leetcode-ui.component.text")
local Line = require("leetcode-ui.component.line")
local Case = require("leetcode.ui.console.components.case")

local log = require("leetcode.logger")

---@class lc.Cases : lc-ui.Group
---@field cases table<integer, lc.Result.Case>
---@field keymaps table<string, function> { mode: string, key: string }
---@field idx integer
---@field parent lc.ui.Console.ResultPopup
local Cases = Group:extend("LeetCases")

function Cases:clear()
    self.parent:clear_keymaps(self.keymaps)
    self.keymaps = {}

    Cases.super.clear(self)
end

function Cases:make_nav()
    local nav = Lines({ padding = { top = 1, bot = 0 } })

    for i, case in ipairs(self.cases) do
        self.keymaps[tostring(i)] = function() self:change(i) end

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

    self.parent:set_keymaps(self.keymaps)

    Cases.super.draw(self, layout)
end

---@param idx integer
function Cases:change(idx)
    if not self.cases[idx] or idx == self.idx then return end

    self.idx = idx
    self.parent:draw()
end

---@param item lc.runtime
---@param testcases string[]
---@param parent lc.ui.Console.ResultPopup
---@return lc.Cases
function Cases:init(item, testcases, parent)
    Cases.super.init(self, { spacing = 1 })

    self.cases = {}
    self.parent = parent
    self.keymaps = {}

    for i, answer in ipairs(item.code_answer) do
        self.cases[i] = Case({
            input = testcases[i],
            output = answer,
            expected = item.expected_code_answer[i],
            std_output = item.std_output_list[i],
        }, item.compare_result:sub(i, i) == "1")
    end

    self:change(1)
end

---@type fun(item: lc.runtime, testcases: string[], parent: lc.ui.Console.ResultPopup): lc.Cases
local LeetCases = Cases

return LeetCases
