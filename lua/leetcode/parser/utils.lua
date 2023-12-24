local log = require("leetcode.logger")
local theme = require("leetcode.theme")

---@class lc.Parser.Utils
local utils = {}

local entities = {
    ["&lt;"] = "<",
    ["&le;"] = "<=",
    ["&gt;"] = ">",
    ["&ge;"] = ">=",
    ["&ne;"] = "!=",
    ["&minus;"] = "-",
    ["&plus;"] = "+",
    ["&oplus;"] = "⊕",
    ["&plusmn;"] = "±",
    ["&cup;"] = "∪",
    ["&times;"] = "×",
    ["&frasl;"] = "/",

    ["&nbsp;"] = " ",
    ["&quot;"] = "\"",
    ["&#39;"] = "'",

    ["&rarr;"] = "",
    ["&larr;"] = "",
    ["&uarr;"] = "↑",
    ["&darr;"] = "↓",

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
    ["&lccode;"] = "`",
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

---@param tag lc.ui.Tag
---@return string
function utils.hl(tag) --
    local tag_names = {}

    for _, v in ipairs(tag.tags) do
        if v.name then table.insert(tag_names, v.name) end
    end

    if tag.name then table.insert(tag_names, tag.name) end

    return theme.get_dynamic(tag_names)
end

return utils
