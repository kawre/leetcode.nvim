local m = require("markup")

---@param props { item: lc.internal_error }
local InternalError = m.component(function(props)
    local item = props.item

    return m.block({
        "internal error",
    })
end)

return InternalError
