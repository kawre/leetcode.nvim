local m = require("markup")

local CaseBlock = m.component(function(props)
    return m.block({
        padding = { 1, 2 },
        style = "LspInlayHint",
        children = m.button(props.children),
    })
end)

return CaseBlock
