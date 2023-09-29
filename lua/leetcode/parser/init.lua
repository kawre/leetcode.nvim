local log = require("leetcode.logger")

local Text = require("leetcode-ui.component.text")
local utils = require("leetcode.parser.utils")

local NuiText = require("nui.text")
local NuiLine = require("nui.line")

---@class lc.Parser2
---@field str string
---@field lang string
---@field parser LanguageTree
---@field ts TreesitterModule
---@field text lc-ui.Text
---@field newline_count integer
local parser = {}
parser.__index = parser

---@private
---
---@param node TSNode
---
---@return lc.Parser.Tag.Attr
function parser:get_attr(node)
    ---@class lc.Parser.Tag.Attr
    ---@field name string
    ---@field value string
    local attr = {}

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "attribute_name" and child:named() then
            attr.name = self:get_text(child)
        elseif ntype == "quoted_attribute_value" and child:named() then
            attr.value = self:get_text(child):gsub("\"", "")
        end
    end

    return attr
end

---@private
---
---@param node TSNode
---
---@return lc.Parser.Tag
function parser:get_tag_data(node)
    ---@class lc.Parser.Tag
    ---@field name string
    ---@field attrs lc.Parser.Tag.Attr[]
    local data = { attrs = {} }

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "tag_name" then
            data.tag = self:get_text(child)
        elseif ntype == "attribute" then
            table.insert(data.attrs, self:get_attr(child))
        end
    end

    return data
end

---@private
---
---@param node TSNode
---
---@return string
function parser:get_text(node) return self.ts.get_node_text(node, self.str) end

function parser:handle_entity(entity)
    if entity == "&lcnl;" then
        if self.newline_count <= 1 then
            self.text:append(self.line)
            self.line = NuiLine()
        end
    elseif entity == "&lcpad;" then
        if self.line:content() ~= "" then self.text:append(self.line) end

        self.line = NuiLine()
        self.text:append(NuiLine())
        self.text:append(NuiLine())
        self.text:append(NuiLine())
    elseif entity == "&lcend;" then
        self.text:append(self.line)
    end

    self.newline_count = (entity == "&lcnl;") and (self.newline_count + 1) or 0
    return utils.entity(entity)
end

function parser:handle_list(tags)
    if self.line:content() ~= "" then return end

    local function get_list_type()
        for _, tag in ipairs(tags) do
            if tag == "ul" or tag == "ol" then return tag end
        end
    end

    local li_type = get_list_type()
    local leftpad = string.rep("\t", vim.fn.count(tags, "li"))

    if li_type == "ul" then
        self.line:append(leftpad .. " ", "LeetCodeIndent")
    else
        self.line:append(leftpad .. "1. ", "LeetCodeIndent")
    end
end

---@param text string
function parser:handle_indent(text)
    if self.line:content() ~= "" then return text end

    self.line:append("\t▎\t", "LeetCodeIndent")
end

---@private
---
---@param node TSNode
---@param tags lc.Parser.Tag
---
---@return nil
---TODO: problem 591, <u>...</u> tag, 429, 2467, 961, 997, 1649, 645, 137
function parser:node_hi(node, tags)
    local text = self:get_text(node)
    local tag = tags[1]

    if vim.tbl_contains(tags, "pre") then self:handle_indent(text) end
    if vim.tbl_contains(tags, "li") then self:handle_list(tags) end
    if node:type() == "entity" then text = self:handle_entity(text) end

    if tag == "sup" then text = "^" .. text end
    if tag == "sub" then text = "_" .. text end

    local nui_text = NuiText(text, utils.hi(tags))
    self.line:append(nui_text)
end

---@private
---@param node TSNode
---@param tags table
function parser:rec_parse(node, tags)
    ---@type lc.Parser.Tag
    local tag_data

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "start_tag" then
            tag_data = self:get_tag_data(child)
        else
            if tag_data then table.insert(tags, 1, tag_data.tag) end
            if ntype == "text" or ntype == "entity" then self:node_hi(child, tags) end
            self:rec_parse(child, tags)
            if tag_data then table.remove(tags, 1) end
        end
    end
end

---@return lc-ui.Text
function parser:parse()
    local root = self.parser:parse()[1]:root()

    self:rec_parse(root, {})

    return self.text
end

---@param str string
local function normalize_html(str)
    local res = str:gsub("​", "")
        :gsub("\t", "")
        :gsub("\r\n", "\n")
        :gsub(
            "<p><strong[^>]*>(Example%s*%d+:)</strong></p>(\n*)",
            "\n\n<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "<p><strong[^>]*>(Constraints:)</strong></p>(\n*)",
            "\n\n<constraints> %1</constraints>\n\n"
        )
        :gsub("<pre>\n*(.-)\n*</pre>", "<pre>\n%1</pre>")
        :gsub("\n*<p>&nbsp;</p>\n*", "&lcpad;")
        :gsub("\n", "&lcnl;")
        :gsub("%s", "&nbsp;")

    return res .. "&lcend;"
end

---@param str string
---@param lang string
function parser:init(str, lang)
    local ts = vim.treesitter
    str = normalize_html(str)
    local _parser = ts.get_string_parser(str, lang)

    local obj = setmetatable({
        str = str,
        ts = ts,
        parser = _parser,
        text = Text:init({}),
        line = NuiLine(),
        newline_count = 0,
    }, self)

    return obj
end

return parser
