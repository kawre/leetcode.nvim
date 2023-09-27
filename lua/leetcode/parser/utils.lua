local log = require("leetcode.logger")

local utils = {}

local entities = {
    ["&lt;"] = "<",
    ["&gt;"] = ">",
    ["&nbsp;"] = " ",
    ["&quot;"] = "\"",
    ["&#39;"] = "'",
    ["&rarr;"] = "",
    ["&larr;"] = "",
}

local highlights = {
    ["p"] = "FloatTitle",
    ["strong"] = "",
    ["em"] = "LeetCodeEmTag",
    ["code"] = "Type",
    ["sup"] = "LeetCodeSupTag",
    ["pre"] = "FloatTitle",
    ["example"] = "DiagnosticHint",
    ["constraints"] = "DiagnosticHint",
    [""] = "",
}

---@param entity string
---@return string
function utils.entity(entity)
    if entities[entity] then
        return entities[entity]
    else
        log.error("Unknown entity: " .. entity)
        return "!" .. entity .. "!"
    end
end

---@param tag string
---@return string
function utils.hi(tag)
    if highlights[tag] then
        return highlights[tag]
    else
        log.warn("Unknown tag: " .. tag)
        return ""
    end
end

return utils
