local m = require("markup")

local Header = m.component(function(props)
    local item = props.item

    -- if item._.submission then
    --     if item._.success then
    --         self:append(" 🎉")
    --     else
    --         self:append(" | ")
    --         self:append(testcases_passed(item), "leetcode_alt")
    --     end
    if not item.status_runtime then
        return
    end

    return m.block({
        m.inline(" Accepted 🎉", "DiagnosticSignOk"),
        m.inline({
            style = "Conceal",
            " | Runtime: ",
            item.status_runtime,
        }),
    })
end)

return Header
