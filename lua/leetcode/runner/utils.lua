local utils = {}

---@param lines string[]
function utils.to_typed_code(lines)
    return table.concat(lines, "\n")
end

return utils
