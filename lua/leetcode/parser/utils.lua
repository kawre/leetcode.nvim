local log = require("leetcode.logger")
local theme = require("leetcode.theme")

---@class lc.Parser.Utils
local utils = {}

utils.entities = {
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
    ["&mdash;"] = "—",
    ["&ndash;"] = "–",

    ["&rdquo;"] = "”",
    ["&rsquo;"] = "’",
    ["&ldquo;"] = "“",
    ["&lsquo;"] = "‘",

    ["&lcpad;"] = "",
    ["&lcnl;"] = "",
    ["&lctab;"] = "\t",
    ["&lcend;"] = "",
    ["&lccode;"] = "`",

    -- Math symbols
    ["&lt;"] = "<",
    ["&gt;"] = ">",
    ["&plus;"] = "+",
    ["&plusmn;"] = "±",
    ["&times;"] = "×",
    ["&frasl;"] = "/",
    ["&forall;"] = "∀",
    ["&part;"] = "∂",
    ["&exist;"] = "∃",
    ["&empty;"] = "∅",
    ["&nabla;"] = "∇",
    ["&isin;"] = "∈",
    ["&notin;"] = "∉",
    ["&ni;"] = "∋",
    ["&prod;"] = "∏",
    ["&sum;"] = "∑",
    ["&minus;"] = "−",
    ["&lowast;"] = "∗",
    ["&radic;"] = "√",
    ["&prop;"] = "∝",
    ["&infin;"] = "∞",
    ["&ang;"] = "∠",
    ["&and;"] = "∧",
    ["&or;"] = "∨",
    ["&cap;"] = "∩",
    ["&cup;"] = "∪",
    ["&int;"] = "∫",
    ["&there4;"] = "∴",
    ["&sim;"] = "∼",
    ["&cong;"] = "≅",
    ["&asymp;"] = "≈",
    ["&ne;"] = "≠",
    ["&equiv;"] = "≡",
    -- ["&le;"] = "<=",
    -- ["&ge;"] = ">=",
    ["&le;"] = "≤",
    ["&ge;"] = "≥",
    ["&sub;"] = "⊂",
    ["&sup;"] = "⊃",
    ["&nsub;"] = "⊄",
    ["&sube;"] = "⊆",
    ["&supe;"] = "⊇",
    ["&oplus;"] = "⊕",
    ["&otimes;"] = "⊗",
    ["&perp;"] = "⊥",
    ["&sdot;"] = "⋅",
}

---@param entity string
---@return string
function utils.entity(entity)
    if utils.entities[entity] then
        return utils.entities[entity]
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
        if v.name then
            table.insert(tag_names, v.name)
        end
    end

    if tag.name then
        table.insert(tag_names, tag.name)
    end

    return theme.get_dynamic(tag_names)
end

return utils
