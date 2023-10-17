---TODO: 2659
---TODO: https://leetcode.com/problems/make-array-empty/
---TODO: 190

local Text = require("leetcode-ui.component.text")
local utils = require("leetcode.parser.utils")
local log = require("leetcode.logger")

local NuiText = require("nui.text")
local NuiLine = require("nui.line")

---@class lc.Parser.Html
---@field str string
---@field parser LanguageTree
---@field ts TreesitterModule
---@field text lc-ui.Text
---@field newline_count integer
---@field ol_count table<integer>
local Html = {}
Html.__index = Html

---@private
---
---@param node TSNode
---
---@return lc.Parser.Tag.Attr
function Html:get_attr(node)
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
---@return lc.Parser.Tag | nil
function Html:get_tag_data(node)
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
function Html:get_text(node) return self.ts.get_node_text(node, self.str) end

function Html:handle_entity(entity)
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

function Html:handle_list(tags)
    if self.line:content() ~= "" then return end

    local function get_list_type()
        for _, tag in ipairs(tags) do
            if tag == "ul" or tag == "ol" then return tag end
        end
    end

    local li_type = get_list_type()
    local li_count = vim.fn.count(tags, "li")
    local leftpad = string.rep("\t", li_count)
    -- local li_icons = { "", "", "" }
    local li_icons = { "*", "-", "+" }

    local text
    if li_type == "ul" then
        local li_icon = li_icons[math.max(1, li_count % (#li_icons + 1))]
        text = string.format("%s%s ", leftpad, li_icon)
    else
        local ol_c = vim.fn.count(tags, "ol")

        self.ol_count[ol_c] = (self.ol_count[ol_c] or 0) + 1
        text = string.format("%s%d. ", leftpad, self.ol_count[ol_c])
    end

    self.line:append(text, "leetcode_list")
end

---@param text string
function Html:handle_indent(text)
    if self.line:content() ~= "" then return text end

    self.line:append("\t▎\t", "leetcode_indent")
end

---@private
---
---@param text string
---@param tag_data lc.Parser.Tag
---
---@return NuiLine
function Html:handle_link(text, tag_data)
    local tag = tag_data.tag
    local link = ""

    if tag == "a" then
        local href = vim.tbl_filter(function(attr)
            if attr.name == "href" then return attr end
        end, tag_data.attrs)[1] or {}
        log.debug(tag_data.attrs)

        link = href.value or ""
    elseif tag == "img" then
        local alt = vim.tbl_filter(function(attr)
            if attr.name == "alt" then return attr end
        end, tag_data.attrs)[1] or {}
        text = alt.value ~= "" and alt.value or "img"

        local src = vim.tbl_filter(function(attr)
            if attr.name == "src" then return attr end
        end, tag_data.attrs)[1] or {}
        link = src.value or ""
    end

    local line = NuiLine()
    line:append(text, "leetcode_ref")
    line:append("->(", "leetcode_normal")
    line:append(link, "leetcode_link")
    line:append(")", "leetcode_normal")

    return line
end

---@private
---
---@param node TSNode
---@param tags lc.Parser.Tag
--@param tag_data lc.Parser.Tag
function Html:node_hl(node, tags, tag_data)
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

    local nui_text
    if tag == "a" or tag == "img" then
        nui_text = self:handle_link(text, tag_data)
    else
        nui_text = NuiText(text, utils.hl(tags))
    end

    self.line:append(nui_text)
end

---@private
---
---@param node TSNode
---@param tags table
function Html:rec_parse(node, tags)
    local tag_data = self:get_tag_data(node)

    for child in node:iter_children() do
        local ntype = child:type()

        if tag_data then table.insert(tags, 1, tag_data.tag) end
        if ntype == "text" or ntype == "entity" then self:node_hl(child, tags, tag_data) end
        self:rec_parse(child, tags)
        if tag_data then table.remove(tags, 1) end
    end
end

function Html:normalize()
    log.debug(self.str)

    self.str = self
        .str
        :gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("\t*<(/?li)>", "<%1>")
        :gsub("\t*<(/?ul)>", "<%1>")
        :gsub("\t*<(/?ol)>", "<%1>")
        :gsub("<strong>(Input:?%s*)</strong>", "<input>%1</input>")
        :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
        :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
        -- :gsub(
        --     "\t*<(li[^>]*)>(.-)\t*</(li)>",
        --     "<%1>%2</%3>\n"
        -- )
        -- :gsub("\t*<(ul[^>]*)>(.-)\t*</(ul)>", "<%1>%2</%3>\n")
        -- :gsub("\t*<(ol[^>]*)>(.-)\t*</(ol)>", "<%1>%2</%3>\n")
        :gsub(
            "<p><strong[^>]*>(Example%s*%d*:?)%s*</strong></p>\n*",
            "\n\n<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "<p><strong[^>]*>(Constraints:?)%s*</strong></p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
        )
        :gsub("<(img[^>]*)/>\n*", "<%1>img</img>")
        :gsub("<pre>\n*(.-)\n*</pre>", "<pre>\n%1</pre>")
        :gsub("\n*<p>&nbsp;</p>\n*", "&lcpad;")
        :gsub("\n", "&lcnl;")
        :gsub("\t", "&lctab;")
        :gsub("%s", "&nbsp;")
        :gsub("<[^>]*>", function(match) return match:gsub("&nbsp;", " ") end)
        :gsub("<a[^>]*>(.-)</a>", function(match) return match:gsub("&#?%w+;", utils.entity) end)
        .. "&lcend;"
end

-- Trim excessive lines
function Html:trim()
    local lines = self.text.lines
    for i = #lines, 1, -1 do
        if lines[i]:content() ~= "" then break end
        table.remove(lines, i)
    end
    self.text.lines = lines

    return self.text
end

---@param html string
---
---@return lc-ui.Text
function Html:parse(html)
    self = setmetatable({
        str = html,
        ts = vim.treesitter,
        text = Text:init(),
        line = NuiLine(),
        newline_count = 0,
        ol_count = {},
    }, self)

    self:normalize()
    local ok, parser = pcall(self.ts.get_string_parser, self.str, "html")
    assert(ok, parser)

    local root = parser:parse()[1]:root()
    self:rec_parse(root, {})

    return self:trim()
end

return Html
