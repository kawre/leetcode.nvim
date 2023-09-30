local log = require("leetcode.logger")

local utils = {}

local entities = {
    ["&lt;"] = "<",
    ["&gt;"] = ">",
    ["&ne;"] = "!=",
    ["&minus;"] = "-",
    ["&plus;"] = "+",
    ["&plusmn;"] = "±",
    ["&cup;"] = "∪",
    ["&times;"] = "×",

    ["&nbsp;"] = " ",
    ["&quot;"] = "\"",
    ["&#39;"] = "'",
    ["&rarr;"] = "",
    ["&larr;"] = "",

    ["&ldquo;"] = "“",
    ["&rdquo;"] = "”",

    ["&lcpad;"] = "",
    ["&lcnl;"] = "",
    ["&lcend;"] = "",
}

local highlights = {
    [""] = "LeetCodeNormal",
    ["strong"] = "LeetCodeBold",
    ["em"] = "LeetCodeItalic",
    ["i"] = "LeetCodeItalic",
    ["code"] = "LeetCodeCode",
    ["example"] = "LeetCodeExample",
    ["constraints"] = "LeetCodeConstraints",

    ["pre"] = "Inherit",
    ["span"] = "Inherit",
    ["p"] = "Inherit",
    ["ul"] = "Inherit",
    ["ol"] = "Inherit",
    ["li"] = "Inherit",
    ["font"] = "Inherit",

    ["a"] = "LeetCodeIndent",
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
    if highlights[tag] and highlights[tag] ~= "Inherit" then return highlights[tag] end

    ---Inherit hi from parent tag
    for _, t in ipairs(tags) do
        if highlights[t] and highlights[t] ~= "Inherit" then return highlights[t] end
    end

    if not highlights[tag] then log.info("Unknown tag: " .. tag) end
    return highlights[""]
end

return utils
