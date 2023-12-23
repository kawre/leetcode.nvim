local theme = require("leetcode.theme")

local utils = require("leetcode.parser.utils")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local ts = vim.treesitter

local log = require("leetcode.logger")

---@class lc.ui.Tag : lc.ui.Group
---@field name string
---@field tags string[]
---@field node TSNode
---@field text string
local Tag = Group:extend("LeetTag")

function Tag:get_text(node) return ts.get_node_text(node, self.text) end

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
    if node:type() ~= "element" then return {} end

    local start_tag
    for child in node:iter_children() do
        local ctype = child:type()

        if ctype == "start_tag" or ctype == "self_closing_tag" then
            start_tag = child
            break
        end
    end

    if not start_tag then return {} end

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

    -- local res = { tag = tag, attrs = attrs }
    return { tag = tag, attrs = attrs }
end

function Tag:parse_helper() --
    ---@param child TSNode
    for child in self.node:iter_children() do
        local ntype = child:type()

        if ntype == "text" then
            self:append(self:get_text(child))
        elseif ntype == "element" then
            self:append(Tag:from(self, child))
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

-- 701
function Tag.trim(lines) --
    if not lines or vim.tbl_isempty(lines) then return {} end

    while not vim.tbl_isempty(lines) and lines[1]:content() == "" do
        table.remove(lines, 1)
    end

    while not vim.tbl_isempty(lines) and lines[#lines]:content() == "" do
        table.remove(lines)
    end

    return lines
end

local function req_tag(str) return require("leetcode-ui.group.tag." .. str) end

-- ---@param node TSNode
-- function Tag:from(node)
-- end

function Tag:contents()
    local items = Tag.super.contents(self)

    for _, value in ipairs(items) do
        value:replace(Tag.trim(value:contents()))
    end

    return items
end

---@param text string
---@param opts lc.ui.opts
---@param node TSNode
---@param tags string[]
---@param tag string
function Tag:init(text, opts, node, tags, tag) --
    Tag.super.init(self, {}, opts or {})

    self.text = text
    self.node = node
    self.tags = tags
    self.name = tag

    log.info(tag)

    self:parse_helper()
end

---@type fun(text: string, opts: lc.ui.opts, node?: TSNode, tags: string[], tag?: string): lc.ui.Tag
local LeetTag = Tag

---@param tag lc.ui.Tag
---@param node TSNode
function Tag.static:from(tag, node)
    local t = {
        pre = req_tag("pre"),
        ul = req_tag("ul"),
        ol = req_tag("ol"),
        img = req_tag("img"),
        a = req_tag("a"),
    }

    local el = tag:get_el_data(node)
    local tags = tag.tags

    -- log.info(tag.name)

    table.insert(tags, el.tag)

    local opts = { hl = theme.get_dynamic(tags) }
    local parsed = (t[tags[#tags]] or LeetTag)(tag.text, opts, node, tags, el.tag)

    table.remove(tags)

    return parsed
end

---@param text string
function Tag.static:parse(text) --
    local ok, parser = pcall(ts.get_string_parser, text, "html")
    assert(ok, parser)
    local root = parser:parse()[1]:root()

    return LeetTag(text, { spacing = 3, hl = "leetcode_normal" }, root, {}, nil)
end

return LeetTag
