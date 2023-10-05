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
    ["&thinsp;"] = " ",
    ["&hellip;"] = "…",
    ["&lfloor;"] = "⌊",
    ["&rfloor;"] = "⌋",
    ["&amp;"] = "&",
    ["&infin;"] = "∞",

    ["&rdquo;"] = "”",
    ["&rsquo;"] = "’",
    ["&ldquo;"] = "“",
    ["&lsquo;"] = "‘",

    ["&lcpad;"] = "",
    ["&lcnl;"] = "",
    ["&lctab;"] = "\t",
    ["&lcend;"] = "",
}

local highlights = {
    [""] = "LeetCodeNormal",
    ["strong"] = "LeetCodeBold",
    ["b"] = "LeetCodeBold",
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
    ["sup"] = "Inherit",
    ["sub"] = "Inherit",
    ["u"] = "Inherit",
    ["small"] = "Inherit",
    ["div"] = "Inherit",

    ["a"] = "Function",
}

---@param entity string
---@return string
function utils.entity(entity)
    if entities[entity] then
        return entities[entity]
        -- return entity
    else
        log.error("unknown enitity: " .. entity)
        return entity
    end
end

---@param tags string[]
---@return string
function utils.hi(tags)
    local tag = tags[1] or ""

    if tag == "a" then log.error("WTETWET") end

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
