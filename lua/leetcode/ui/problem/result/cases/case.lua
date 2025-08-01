local m = require("markup")
local CaseBlock = require("leetcode.ui.problem.result.cases.block")
local Stdout = require("leetcode.ui.problem.result.stdout")
local Input = require("leetcode.ui.problem.result.input")

---@param props { input: string[], output: string, expected: string, stdout: string, params: string[] }
local Case = m.component(function(props)
    local expanded, set_expanded = m.hooks.variable(true)

    local output = props.output
    local expected = props.expected
    local params = props.params

    return m.block({
        spacing = 1,
        Input({ input = props.input, params = params }),
        Stdout({ stdout = props.stdout }),
        m.block({
            m.inline("Output"),
            CaseBlock(output),
        }),
        m.block({
            m.inline("Expected"),
            CaseBlock(expected),
        }),
    })
end)

return Case
