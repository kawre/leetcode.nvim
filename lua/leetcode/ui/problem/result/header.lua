local m = require("markup")

local function testcases_passed(item)
    local correct = item.total_correct ~= vim.NIL and item.total_correct or "0"
    local total = item.total_testcases ~= vim.NIL and item.total_testcases or "0"

    return ("%d/%d %s"):format(correct, total, "testcases passed")
end

---@param props { item: lc.interpreter_response }
local Header = m.component(function(props)
    local item = props.item

    return m.block({
        m.inline(item._.title, item._.hl),
        item._.submission
                and (
                    item._.success and m.inline(" 🎉") --
                    or m.inline(" | " .. testcases_passed(item), "leetcode_alt")
                )
            or item.status_runtime
                and m.inline(" | Runtime: " .. item.status_runtime, "Conceal"),
    })
end)

return Header
