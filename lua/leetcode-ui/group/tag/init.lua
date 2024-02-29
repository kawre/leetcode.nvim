local Group = require("leetcode-ui.group")
local Indent = require("nui.text")
local Normalizer = require("leetcode.parser.normalizer")

local ts = vim.treesitter
local utils = require("leetcode.parser.utils")
local log = require("leetcode.logger")

---@class lc.ui.Tag : lc.ui.Group
---@field name string
---@field tags lc.ui.Tag[]
---@field node TSNode
---@field text string
local Tag = Group:extend("LeetTag")

---@param text string
function Tag.normalize(text)
    local norm = text
        :gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("<br />", "\n")
        :gsub("<meta[^>]*/>", "")
        :gsub("(\n+)(\t+)", "%1")
        :gsub("<(/?li)>\n*", "<%1>\n\n")
        :gsub("\n*(<ul[^>]*>)\n*", "\n\n%1\n")
        :gsub("\n*(<ol[^>]*>)\n*", "\n\n%1\n")
        :gsub("\n*(<pre[^>]*>)", "\n\n%1\n")
        :gsub("<p>(%s+)</p>", "&lcpad;")
        :gsub("<([^>]+)>(%s*)</%1>", "%2")
        -- :gsub("<sub>(%s*)</sub>", "%1")
        -- :gsub("<sup>(%s*)</sup>", "%1")
        -- :gsub("<p>(%s*)</p>", "%1")
        :gsub(
            "<strong>(Input:?%s*)</strong>",
            "<input>%1</input>"
        )
        :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
        :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
        :gsub("<strong>(Follow-up:%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
        :gsub(
            "\n*<p><strong[^>]*>(Example%s*%d*:?)%s*</strong></p>\n*",
            "\n\n<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "\n*<p><strong[^>]*>(Constraints:?)%s*</strong></p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
        )
        :gsub("\n*(<img[^>]*/?>)\n*", "\n\n%1\n\n")
        :gsub("\n*<p>&nbsp;</p>\n*", "&lcpad;")
        :gsub("\n", "&lcnl;")
        :gsub("\t", "&lctab;")
        :gsub("%s", "&nbsp;")
        :gsub("<[^>]*>", function(match)
            return match:gsub("&nbsp;", " ")
        end)
    -- :gsub("<a[^>]*>(.-)</a>", function(match) return match:gsub("&#?%w+;", utils.entity) end)

    log.debug(text)
    log.debug(norm:gsub("&lcnl;", "&lcnl;\n"), false)

    return norm
end

function Tag:add_indent(item, text)
    if item.class and item.class.name == "LeetLine" then
        table.insert(item._texts, 1, Indent(text or "\t", "leetcode_indent"))
        return
    end

    for _, c in ipairs(item:contents()) do
        self:add_indent(c, text)
    end
end

function Tag:get_text(node)
    return ts.get_node_text(node, self.text)
end

---@param node TSNode
---
---@return lc.Parser.Tag.Attr
function Tag:get_attr(node)
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

-- 1206
---@param node TSNode
function Tag:get_el_data(node)
    if node:type() ~= "element" then
        return {}
    end

    local start_tag
    for child in node:iter_children() do
        local ctype = child:type()

        if ctype == "start_tag" or ctype == "self_closing_tag" then
            start_tag = child
            break
        end
    end

    if not start_tag then
        return {}
    end

    local tag, attrs = nil, {}
    for child in start_tag:iter_children() do
        local ntype = child:type()
        if ntype == "tag_name" then
            tag = self:get_text(child)
        elseif ntype == "attribute" then
            local attr = self:get_attr(child)
            attrs[attr.name] = attr.value
        end
    end

    return { tag = tag, attrs = attrs }
end

function Tag:parse_node() --
    ---@param child TSNode
    for child in self.node:iter_children() do
        local ntype = child:type()

        if ntype == "text" or ntype == "ERROR" then
            self:append(self:get_text(child))
        elseif ntype == "element" then
            self:append(self:from(child))
        elseif ntype == "entity" then
            local text = self:get_text(child)

            if text == "&lcnl;" then
                self:endl()
            elseif text == "&lcpad;" then
                self:endgrp()
            else
                self:append(utils.entity(text))
            end
        end
    end
end

function Tag.trim(lines) --
    if not lines or vim.tbl_isempty(lines) then
        return {}
    end

    while not vim.tbl_isempty(lines) and lines[1]:content() == "" do
        table.remove(lines, 1)
    end

    while not vim.tbl_isempty(lines) and lines[#lines]:content() == "" do
        table.remove(lines)
    end

    return lines
end

local function req_tag(str)
    return require("leetcode-ui.group.tag." .. str)
end

function Tag:contents()
    local items = Tag.super.contents(self)

    for _, value in ipairs(items) do
        value:replace(Tag.trim(value:contents()))
    end

    return items
end

---@param node TSNode
function Tag:from(node)
    local tbl = {
        pre = req_tag("pre"),
        blockquote = req_tag("pre"),

        ul = req_tag("list.ul"),
        ol = req_tag("list.ol"),
        li = req_tag("li"),

        img = req_tag("img"),
        a = req_tag("a"),

        sub = req_tag("sub"),
        sup = req_tag("sup"),
    }

    local tags = self.tags
    local el = self:get_el_data(node)

    table.insert(tags, self)
    local parsed = (tbl[el.tag] or Tag)(self.text, {}, node, tags)
    table.remove(tags)

    return parsed
end

---@param text string
---@param opts lc.ui.opts
---@param node TSNode
---@param tags lc.ui.Tag[]
function Tag:init(text, opts, node, tags) --
    self.text = text
    self.node = node
    self.tags = tags

    self.data = self:get_el_data(node)
    self.name = self.data.tag

    opts = vim.tbl_extend("force", {
        hl = utils.hl(self),
    }, opts or {})

    Tag.super.init(self, {}, opts)

    self:parse_node()
end

---@type fun(text: string, opts: lc.ui.opts, node: TSNode, tags: lc.ui.Tag[]): lc.ui.Tag
local LeetTag = Tag

---@param text string
function Tag.static:parse(text)
    ---@type string
    local normalized = Normalizer:norm(text)

    local ok, parser = pcall(ts.get_string_parser, normalized, "html")

    if not ok then
        local Plain = require("leetcode.parser.plain")
        return Plain:parse(text)
    end

    local root = parser:parse()[1]:root()

    return LeetTag(normalized, { spacing = 3, hl = "leetcode_normal" }, root, {})
end

-- parser = ts.get_string_parser(normalized, "html")
-- root = parser:parse()[1]:root()

return LeetTag
