local log = require("leetcode.logger")

local Group = require("leetcode-ui.component.group")
local Text = require("leetcode-ui.component.text")
local Case = require("leetcode.ui.console.components.case")

local NuiLine = require("nui.line")

---@class lc.Cases : lc-ui.Group
---@field nav lc-ui.Text
---@field case lc-ui.Group
---@field cases table<integer, lc.Result.Case>
---@field keymaps { mode: string, key: string }
---@field idx integer
---@field parent lc.Result
local Cases = {}
Cases.__index = Cases
setmetatable(Cases, Group)

function Cases:clear()
    for _, map in ipairs(self.keymaps) do
        pcall(function() self.parent.popup:unmap(map.mode, map.key) end)
    end
    self.keymaps = {}
    Group.clear(self)
end

function Cases:update_nav()
    local cases = NuiLine()

    for i, case in ipairs(self.cases) do
        local text = NuiLine()
        local hl = ("%s%s"):format(self.idx == i and "focus_" or "", case.passed and "ok" or "err")
        text:append((" Case (%d) "):format(i), "leetcode_case_" .. hl)

        local keymap = { mode = "n", key = tostring(i) }
        self.parent.popup:map(keymap.mode, keymap.key, function() self:change(i) end)
        table.insert(self.keymaps, keymap)

        cases:append(text)
        if i ~= #self.cases then cases:append(" ") end
    end

    self.nav.lines = { cases }
end

---@param idx integer
function Cases:change(idx)
    if not self.cases[idx] or idx == self.idx then return end
    self.case.components = { self.cases[idx] }
    self.idx = idx
    self:update_nav()
    self.parent:draw()
end

---@param item lc.runtime
---@param testcases string[]
---@param parent lc.Result
---@return lc.Cases
function Cases:init(item, testcases, parent)
    local group = Group:init({}, { spacing = 1 })
    self = setmetatable(group, self)

    self.cases = {}
    self.parent = parent
    self.keymaps = {}

    for i, answer in ipairs(item.code_answer) do
        self.cases[i] = Case:init(
            testcases[i],
            answer,
            item.expected_code_answer[i],
            item.std_output_list[i],
            item.compare_result:sub(i, i) == "1"
        )
    end

    self.nav = Text:init({}, { padding = { top = 1, bot = 0 } })
    self:append(self.nav)

    self.case = Group:init({})
    self:append(self.case)
    self:change(1)

    return self ---@diagnostic disable-line
end

return Cases
