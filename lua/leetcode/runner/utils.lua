local utils = {}

---@param lines string[]
function utils.to_typed_code(lines)
    for i, line in ipairs(lines) do
        lines[i] = line:gsub("%s+", " ")
    end

    return table.concat(lines, "\n")
end

return utils
