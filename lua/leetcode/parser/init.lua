local Text = require("leetcode-ui.component.text")
local Line = require("nui.line")
local log = require("leetcode.logger")

---@class lc.Parser2
---@field str string
---@field lang string
---@field parser LanguageTree
---@field ts TreesitterModule
---@field text lc-ui.Text
local parser = {}
parser.__index = parser

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
    ["&#39;"] = "'",
    ["&lctab;"] = "\t ",
    ["&rarr;"] = "",
    ["&larr;"] = "",
}

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

---@private
---
---@param node TSNode
---@param tag_data lc.Parser.Tag
---
---@return nil
---TODO: problem 591, <u>...</u> tag,
function parser:highlight_node(node, tag_data)
    local text = self:get_text(node)
    -- log.info(text)
    -- if not tag_data then
    --     text = text:gsub("&nbsp;", " ")
    --     return self.text:append(text)
    -- end

    local data = tag_data or {}
    local tag = data.tag

    if node:type() == "entity" then
        if text == "&lcnl;" then
            self.text:append(self.line)
            self.line = Line()
            return
        else
            text = entities[text] or text
        end
    end
    if tag == "sup" then text = "^" .. text end
    if tag == "sub" then text = "_" .. text end

    local nui_text = Line()
    nui_text:append(text, theme[tag])

    for _, attr in ipairs(data.attrs or {}) do
        if attr.name == "class" then
            if attr.value == "example" then
                nui_text = Line()
                nui_text:append(text, "DiagnosticInfo")
            end
        end
    end

    self.line:append(nui_text)
end

---@private
---@param node TSNode
function parser:rec_parse(node)
    ---@type lc.Parser.Tag
    local tag_data

    for child in node:iter_children() do
        local ntype = child:type()

        if ntype == "start_tag" then
            tag_data = self:get_tag_data(child)
        elseif ntype == "text" or ntype == "entity" then
            self:highlight_node(child, tag_data)
        elseif child:named() then
            self:rec_parse(child)
        end
    end
end

---@return lc-ui.Text
function parser:parse()
    local root = self.parser:parse()[1]:root()

    self:rec_parse(root)
    return self.text
end

---@param str string
local function normalize(str)
    local res = str:gsub("\n", "&lcnl;"):gsub("\t", "&lctab;"):gsub(" ", "&nbsp;")
    return res
end

---@param str string
---@param lang string
function parser:init(str, lang)
    local ts = vim.treesitter
    str = normalize(str)
    local _parser = ts.get_string_parser(normalize(str), lang)

    local obj = setmetatable({
        str = str,
        ts = ts,
        parser = _parser,
        text = Text:init({}),
        line = Line(),
    }, self)

    return obj
end

return parser
