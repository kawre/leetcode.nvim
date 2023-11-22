local Lines = require("leetcode-ui.lines")
local t = require("leetcode.translator")

---@class lc.Result.Header : lc-ui.Lines
local Header = Lines:extend("LeetHeader")

local function testcases_passed(item)
    local correct = item.total_correct ~= vim.NIL and item.total_correct or "0"
    local total = item.total_testcases ~= vim.NIL and item.total_testcases or "0"

    return ("%d/%d %s"):format(correct, total, t("testcases passed"))
end

---@param item lc.interpreter_response
function Header:init(item) --
    Header.super.init(self)

    self:append(item._.title, item._.hl)
    if item._.submission then
        if item._.success then
            self:append(" 🎉")
        else
            self:append(" | ")
            self:append(testcases_passed(item), "leetcode_alt")
        end
    elseif item.status_runtime then
        self:append(" | ")
        self:append(("%s: %s"):format(t("Runtime"), item.status_runtime), "leetcode_alt")
    end
end

---@type fun(item: lc.runtime): lc.Result.Header
local LeetHeader = Header

return LeetHeader
