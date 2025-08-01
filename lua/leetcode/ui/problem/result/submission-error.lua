local m = require("markup")
local Case = require("leetcode.ui.problem.result.cases.case")

---@param props { item: lc.submission }
local SubmissionError = m.component(function(props)
    local item = props.item ---@type lc.submission

    return Case({
        input = vim.split(item.input, "\n"),
        output = item.code_output,
        expected = item.expected_output,
        std_output = item.std_output,
    })
end)

return SubmissionError
