local log = require("leetcode.logger")

---@class lc.Parser.Utils
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
    ["&lccode;"] = "`",
}

local highlights = {
    strong = "bold",
    b = "bold",
    em = "italic",
    i = "italic",
    code = "code",
    example = "example",
    constraints = "constraints",
    a = "link",
    u = "underline",

    -- pre = "",
    -- span = "",
    -- p = "",
    -- ul = "",
    -- ol = "",
    -- li = "",
    -- font = "",
    -- sup = "",
    -- sub = "",
    -- small = "",
    -- div = "",
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
function utils.hl(tags)
    if vim.tbl_isempty(tags) then return "" end

    local name = "leetcode_dyn_" .. table.concat(tags, "_")
    if _Lc_dyn_hl[name] then return name end

    local default = require("leetcode.theme.default").get()

    local theme = default["normal"]
    for _, tag in ipairs(tags) do
        local hl = highlights[tag]
        if hl then theme = vim.tbl_deep_extend("force", theme, default[hl]) end
    end

    if pcall(vim.api.nvim_set_hl, 0, name, theme) then
        _Lc_dyn_hl[name] = theme
        return name
    else
        return "leetcode_normal"
    end
end

return utils
