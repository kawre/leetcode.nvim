local m = require("markup")

local CaseBlock = m.component(function(props)
    return m.block({
        padding = { 1, 2 },
        style = "LspInlayHint",
        children = props.children,
    })
end)

local Case = m.component(function(props)
    local input = Markup.list(props.input)
    local output = props.output
    local expected = props.expected
    local std_output = props.std_output
    local console = props.console ---@type leet.problem.console
    local params = console.problem.problem.meta_data.params

    local std_lines = Markup.list(vim.split(std_output or "", "\n", { trimempty = true }))

    return m.block({
        spacing = 1,
        m.block({
            m.inline("Input"),
            m.block({
                spacing = 1,
                input:map(function(case, i)
                    local ok, param = pcall(function()
                        return params[i].name
                    end)
                    return CaseBlock({
                        ok and m.block(param .. " ="),
                        m.block(case),
                    })
                end),
            }),
        }),
        m.block({
            m.inline(" Stdout"),
            CaseBlock(std_lines:map(function(line)
                return m.block(line)
            end)),
        }),
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
