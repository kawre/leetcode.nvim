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
    ["&plusmn;"] = "±",
    ["&cup;"] = "∪",
    ["&times;"] = "×",
    ["&frasl;"] = "/",

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

---@param tags string[]
---@return string
function utils.hl(tags) return theme.get_dynamic(vim.deepcopy(tags)) end

return utils
