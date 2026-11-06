local m = require("markup")
local CaseBlock = require("leetcode.ui.problem.result.cases.block")

---@param props { stdout: string }
local Stdout = m.component(function(props)
    local expanded = m.signal(true)

    local std_lines = Markup.list(vim.split(props.stdout or "", "\n", { trimempty = true }))

    if #std_lines == 0 then
        return
    end

    return m.block({
        m.block({
            width = "fit",
            on_press = function()
                expanded(not expanded())
            end,
            m.inline(function()
                return expanded() and "" or ""
            end),
            " Stdout ",
        }),
        m.show(expanded, function()
            return CaseBlock(std_lines:map(function(line)
                return m.block(line)
            end))
        end),
    })
end)

return Stdout
