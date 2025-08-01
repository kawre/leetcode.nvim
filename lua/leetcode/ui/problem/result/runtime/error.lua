local m = require("markup")
local Header = require("leetcode.ui.problem.result.header")
local Stdout = require("leetcode.ui.problem.result.stdout")
local Input = require("leetcode.ui.problem.result.input")

---@param props { item: lc.runtime_error }
local RuntimeError = m.component(function(props)
    local item = props.item
    local params = item._.params or {}

    return {
        m.block({
            Header({ item = item }),
            Markup.list(vim.split(item.full_runtime_error, "\n")):map(function(line)
                return m.block(line)
            end),
        }),
        item._.submission
                and m.block({
                    Input({
                        title = m.block(
                            (" %s"):format("Last Executed Input"),
                            "leetcode_normal"
                        ),
                        input = vim.split(item.last_testcase, "\n"),
                        params = params,
                    }),
                    item.std_output and Stdout({ stdout = item.std_output }),
                })
            or item.std_output_list
                and m.block({
                    Stdout({ stdout = item.std_output_list[#item.std_output_list] }),
                }),
    }
end)

return RuntimeError
