local m = require("markup")
local Case = require("leetcode.ui.problem.result.cases.case")

---@param props { item: lc.runtime, console: leet.problem.console }
local Cases = m.component(function(props)
    local active = m.signal(1)

    local item = props.item
    local console = props.console

    local total = item.total_testcases ~= vim.NIL and item.total_testcases or 0
    local testcases = console.testcase:by_id(item.submission_id)

    for i = 1, total do
        m.use_key(tostring(i), function()
            active(i)
        end)
    end

    local cases = Markup.list(testcases):map(function(case, i)
        return Case({
            input = case,
            output = item.code_answer[i],
            expected = item.expected_code_answer[i],
            stdout = item.std_output_list[i],
            params = item._.params,
        })
    end)

    local nav = Markup.list(testcases):map(function(_, i)
        return m.inline({
            style = function()
                return active() == i and "Error" or "DiagnosticOk"
            end,
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
        function()
            return cases[active()]
        end,
    })
end)

return Cases
