local m = require("markup")
local Input = require("leetcode.ui.problem.result.input")
local Stdout = require("leetcode.ui.problem.result.stdout")

---@param props { item: lc.limit_exceeded_error }
local LimitExceed = m.component(function(props)
    local item = props.item

    if item._.submission then
        return m.block({
            Input({
                title = (" %s"):format("Last Executed Input"),
                input = vim.split(item.last_testcase, "\n"),
                params = item._.params,
            }),
            Stdout({ stdout = item.std_output }),
        })
    else
        return Stdout({ stdout = item.std_output_list[#item.std_output_list] })
    end
end)

return LimitExceed
