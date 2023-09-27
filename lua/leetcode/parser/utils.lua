local log = require("leetcode.logger")

local utils = {}

local entities = {
    ["&lt;"] = "<",
    ["&gt;"] = ">",
    ["&ne;"] = "!=",

    ["&nbsp;"] = " ",
    ["&quot;"] = "\"",
    ["&#39;"] = "'",
    ["&rarr;"] = "",
    ["&larr;"] = "",

    ["&lcpad;"] = "",
    ["&lcnl;"] = "",
    ["&lcend;"] = "",
}

local highlights = {
    [""] = "LeetCodeNormal",
    ["p"] = "LeetCodeNormal",
    ["strong"] = "LeetCodeBold",
    ["em"] = "LeetCodeItalic",
    ["code"] = "LeetCodeCode",
    ["pre"] = "LeetCodeNormal",
    ["example"] = "LeetCodeExample",
    ["constraints"] = "LeetCodeConstraints",
    ["ul"] = "LeetCodeNormal",
    ["font"] = "LeetCodeNormal",
}

---@param entity string
---@return string
function utils.entity(entity)
    if entities[entity] then
        return entities[entity]
    else
        log.error("unknown enitity: " .. entity)
        return entity
    end
end

---@param tags string[]
---@return string
function utils.hi(tags)
    local tag = tags[1] or ""
    -- if not tag then return highlights["p"] end

    if highlights[tag] then return highlights[tag] end

    ---Inherit hi from parent tag
    for _, t in ipairs(tags) do
        if highlights[t] then return highlights[t] end
    end

    log.warn("Unknown tag: " .. tag)
    return ""
end

return utils
