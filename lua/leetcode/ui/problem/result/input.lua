local m = require("markup")
local CaseBlock = require("leetcode.ui.problem.result.cases.block")

---@param props { input: string[], params: string[], title?: any }
local Input = m.component(function(props)
    return m.block({
        props.title or "Input",
        m.block({
            spacing = 1,
            Markup.list(props.input):map(function(case, i)
                local ok, param = pcall(function()
                    return props.params[i].name
                end)
                return CaseBlock({
                    ok and m.block(param .. " ="),
                    m.block(case),
                })
            end),
        }),
    })
end)

return Input
