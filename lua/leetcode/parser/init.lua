local log = require("leetcode.logger")
local Text = require("nui.text")

---@class lc.Parser
local M = {}

---@type TreesitterModule, string, NuiText[]
local ts, html, nui_texts

local theme = {
    ["p"] = "LeetCodePTag",
    ["em"] = "LeetCodeEmTag",
    ["strong"] = "LeetCodeStrongTag",
    ["code"] = "LeetCodeCodeTag",
    ["sup"] = "LeetCodeSupTag",
    ["pre"] = "LeetCodePreTag",
}

local entities = {
    ["&lt;"] = "<",
    ["&gt;"] = ">",
    ["&nbsp;"] = " ",
}

---@param node TSNode
---@param tag_name string
---
---@return NuiText
local highlight_node = function(node, tag_name)
    local text = ts.get_node_text(node, html)

    if node:type() == "entity" then text = entities[text] or text end
    if tag_name == "sup" then text = "^" .. text end

    local nui_text = Text(text, theme[tag_name] or "Normal")

    table.insert(nui_texts, nui_text)
end

---@param node TSNode
---
---@return string|nil
local function get_tag_name(node)
    local tag_name

    for child in node:iter_children() do
        if child:type() == "tag_name" and child:named() then
            tag_name = ts.get_node_text(child, html)
        end
    end

    return tag_name
end

---@param node TSNode
local function parse_nodes(node)
    local tag_name

    for child in node:iter_children() do
        local ntype = child:type()

        if not tag_name and ntype == "start_tag" or ntype == "end_tag" then
            tag_name = get_tag_name(child)
        elseif ntype == "text" or ntype == "entity" then
            highlight_node(child, tag_name)
        elseif child:named() then
            parse_nodes(child)
        end
    end
end

---@param to_parse string
---
---@return NuiText[]
function M.parse(to_parse)
    ts, html, nui_texts = vim.treesitter, to_parse, {}

    local parser = ts.get_string_parser(html, "html")
    local tree = parser:parse()[1]

    parse_nodes(tree:root())

    return nui_texts
end

return M
