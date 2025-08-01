local m = require("markup")
local Case = require("leetcode.ui.problem.result.cases.case")

local Cases = m.component(function(props)
    local active, set_active = m.hooks.variable(1)

    local item = props.item ---@type lc.runtime
    local console = props.console ---@type leet.problem.console

    local total = item.total_testcases ~= vim.NIL and item.total_testcases or 0
    local testcases = console.testcase:by_id(item.submission_id)
    local win = m.hooks.window()

    m.hooks.effect(function()
        local unmaps = {}
        for i = 1, total do
            local unmap = win:map("n", tostring(i), function()
                set_active(i)
            end)
            table.insert(unmaps, unmap)
        end
        return function()
            for _, v in ipairs(unmaps) do
                v()
            end
        end
    end, {})

    local cases = Markup.list(testcases):map(function(case, i)
        return Case({
            input = case,
            output = item.code_answer[i],
            expected = item.expected_code_answer[i],
            stdout = item.std_output_list[i],
            console = console,
        })
    end)

    local nav = Markup.list(testcases):map(function(_, i)
        return m.inline({
            style = active == i and "Error" or "DiagnosticOk",
            m.inline("Case "),
            m.inline((" (%d) "):format(i)),
        })
    end)

    return m.block({
        spacing = 1,
        margin = { 1, 2 },
        m.inline({
            spacing = 1,
            nav,
        }),
        cases[active],
    })
end)

return Cases
