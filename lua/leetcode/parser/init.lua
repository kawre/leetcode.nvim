local log = require("leetcode.logger")
local Text = require("nui.text")
local Line = require("nui.line")

---@class lc.Parser
local M = {}

---@type TreesitterModule, string, NuiLine
local ts, html, line

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
    ["&quot;"] = "\"",
}

---@param node TSNode
---
---@return string
local function get_text(node) return ts.get_node_text(node, html) end

---@param node TSNode
---
---@return lc.Parser.Tag.Attr
local function get_attr(node)
    ---@class lc.Parser.Tag.Attr
    ---@field name string
    ---@field value string
    local attr = {}

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "attribute_name" and child:named() then
            attr.name = get_text(child)
        elseif ntype == "quoted_attribute_value" and child:named() then
            attr.value = get_text(child):gsub("\"", "")
        end
    end

    return attr
end

---@param node TSNode
---
---@return lc.Parser.Tag
local function get_tag_data(node)
    ---@class lc.Parser.Tag
    ---@field name string
    ---@field attrs lc.Parser.Tag.Attr[]
    local data = {
        attrs = {},
    }

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "tag_name" then
            data.tag = get_text(child)
        elseif ntype == "attribute" then
            table.insert(data.attrs, get_attr(child))
        end
    end

    return data
end

---@param node TSNode
---@param tag_data lc.Parser.Tag
---
---@return nil
local function highlight_node(node, tag_data)
    local text = get_text(node)
    if not tag_data then
        text = text:gsub("&nbsp;", " ")
        return line:append(text)
    end

    local data = tag_data
    local tag = data.tag

    if node:type() == "entity" then text = entities[text] or text end
    if tag == "sup" then text = "^" .. text end
    if tag == "sub" then text = "_" .. text end

    local nui_text = Text(text, theme[tag] or "Normal")

    for _, attr in ipairs(data.attrs) do
        if attr.name == "class" then
            if attr.value == "example" then nui_text = Text(text, "DiagnosticInfo") end
        end
    end

    line:append(nui_text)
end

---@param node TSNode
local function parse_nodes(node)
    ---@type lc.Parser.Tag
    local tag_data

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "start_tag" then
            tag_data = get_tag_data(child)
        elseif ntype == "text" or ntype == "entity" then
            highlight_node(child, tag_data)
        elseif child:named() then
            parse_nodes(child)
        end
    end
end

---@param to_parse string
---
---@return NuiLine
function M.parse(to_parse)
    -- to_parse = to_parse:gsub(" ", "&nbsp;")
    ts, html, line = vim.treesitter, to_parse, Line()

    local parser = ts.get_string_parser(html, "html")
    local tree = parser:parse()[1]

    parse_nodes(tree:root())

    return line
end

return M
