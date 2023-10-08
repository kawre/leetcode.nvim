---TODO: <blockquote>
---TODO: <a> parser
---TODO: <img> parser
---TODO: <u> parser
---TODO: question duplication
---TODO: Q2066

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
---@field ol_count table<integer>
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

---@class lc.Parser.Tag
---@field tag string
---@field attrs lc.Parser.Tag.Attr[]

---@private
---
---@param node TSNode
---
---@return lc.Parser.Tag | nil
function parser:get_tag_data(node)
    if node:type() ~= "element" then return end

    local start_tag
    for child in node:iter_children() do
        local ctype = child:type()
        if ctype == "start_tag" or ctype == "self_closing_tag" then
            start_tag = child
            break
        end
    end
    if not start_tag then return end

    local tag, attrs = nil, {}
    for child in start_tag:iter_children() do
        local ntype = child:type()

        if ntype == "tag_name" then
            tag = self:get_text(child)
        elseif ntype == "attribute" then
            table.insert(attrs, self:get_attr(child))
        end
    end

    local res = { tag = tag, attrs = attrs }
    return tag and res or nil
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

        self.newline_count = self.newline_count + 1
    elseif entity == "&lcpad;" then
        if self.line:content() ~= "" then self.text:append(self.line) end

        self.line = NuiLine()
        self.text:append({ NuiLine(), NuiLine(), NuiLine() })
    elseif entity == "&lcend;" then
        self.text:append(self.line)
    end

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
    local li_count = vim.fn.count(tags, "li")
    local leftpad = string.rep("\t", li_count)
    local li_icons = { "", "", "" }

    local text
    if li_type == "ul" then
        local li_icon = li_icons[math.max(1, li_count % (#li_icons + 1))]
        text = string.format("%s%s ", leftpad, li_icon)
    else
        local ol_c = vim.fn.count(tags, "ol")

        self.ol_count[ol_c] = (self.ol_count[ol_c] or 0) + 1
        text = string.format("%s%d. ", leftpad, self.ol_count[ol_c])
    end

    self.line:append(text, "LeetCodeList")
end

---@param text string
function parser:handle_indent(text)
    if self.line:content() ~= "" then return text end

    self.line:append("\t▎\t", "LeetCodeIndent")
end

---@private
---
---@param text string
---@param tag_data lc.Parser.Tag
---
---@return NuiLine
function parser:handle_link(text, tag_data)
    local line = NuiLine()

    local href
    for _, attr in ipairs(tag_data.attrs) do
        if attr.name == "href" then href = attr.value end
    end
    if not href then return line end

    line:append("[", "LeetCodeIndent")
    line:append(text, "LeetCodeLink")
    line:append(string.format("](%s)", href), "LeetCodeIndent")

    return line
end

function parser:handle_img(tag_data)
    log.debug(tag_data)
    local tag = tag_data.tag
    if tag ~= "img" then return end
    local line = NuiLine()

    local src, alt
    for _, attr in ipairs(tag_data.attrs) do
        if attr.name == "src" then src = attr.value end
        if attr.name == "alt" then alt = attr.value end
    end
    if not src then return end
    alt = alt or ""

    line:append(string.format("[%s](", alt ~= "" and alt or "img"), "LeetCodeIndent")
    line:append(src, "LeetCodeLink")
    line:append(")", "LeetCodeIndent")

    self.text:append(line)
end

---@private
---
---@param node TSNode
---@param tags lc.Parser.Tag
--@param tag_data lc.Parser.Tag
function parser:node_hi(node, tags, tag_data)
    local text = self:get_text(node)
    local tag = tags[1]

    if vim.tbl_contains(tags, "pre") or vim.tbl_contains(tags, "blockquote") then
        self:handle_indent(text)
    end
    if not vim.tbl_contains(tags, "ol") then self.ol_count = {} end

    if node:type() == "entity" then
        if vim.tbl_contains(tags, "li") and text ~= "&lcnl;" then self:handle_list(tags) end
        text = self:handle_entity(text)
    else
        if vim.tbl_contains(tags, "li") then self:handle_list(tags) end
        self.newline_count = 0
    end

    if tag == "sup" then text = "^" .. text end
    if tag == "sub" then text = "_" .. text end

    local nui_text = tag == "a" and self:handle_link(text, tag_data)
        or NuiText(text, utils.hi(tags))

    self.line:append(nui_text)
end

---@private
---
---@param node TSNode
---@param tags table
function parser:rec_parse(node, tags)
    local tag_data = self:get_tag_data(node)
    log.debug(self:get_text(node))
    ---handle img
    if tag_data and tag_data.tag == "img" then return self:handle_img(tag_data) end

    ---handle rest
    for child in node:iter_children() do
        local ntype = child:type()

        if tag_data then table.insert(tags, 1, tag_data.tag) end
        if ntype == "text" or ntype == "entity" then self:node_hi(child, tags, tag_data) end
        self:rec_parse(child, tags)
        if tag_data then table.remove(tags, 1) end
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
        :gsub("\r\n", "\n")
        :gsub("\t*<(/?li)>", "<%1>")
        :gsub("\t*<(/?ul)>", "<%1>")
        :gsub("\t*<(/?ol)>", "<%1>")
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
        :gsub("\t", "&lctab;")
        :gsub("%s", "&nbsp;")
        :gsub("<[^>]*>", function(match) return match:gsub("&nbsp;", " ") end)
        :gsub("<a[^>]*>.-</a>", function(match) return match:gsub("&nbsp;", " ") end)

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
        text = Text:init(),
        line = NuiLine(),
        newline_count = 0,
        ol_count = {},
    }, self)

    return obj
end

return parser
