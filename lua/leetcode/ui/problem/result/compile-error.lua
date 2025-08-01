local m = require("markup")

---@param props { item: lc.compile_error }
local CompileError = m.component(function(props)
    local item = props.item

    return m.block({
        Markup.list(vim.split(item.full_compile_error, "\n")):map(function(line)
            return m.block(line)
        end),
    })
end)

return CompileError
