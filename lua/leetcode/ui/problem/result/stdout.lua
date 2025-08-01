local m = require("markup")
local CaseBlock = require("leetcode.ui.problem.result.cases.block")

---@param props { stdout: string }
local Stdout = m.component(function(props)
    local expanded, set_expanded = m.hooks.variable(true)

    local std_lines = Markup.list(vim.split(props.stdout or "", "\n", { trimempty = true }))

    if #std_lines == 0 then
        return
    end

    return m.block({
        m.block({
            m.button(expanded and "" or ""),
            " Stdout ",
        }),
        expanded and CaseBlock(std_lines:map(function(line)
            return m.block(line)
        end)),
    })
end)

return Stdout
