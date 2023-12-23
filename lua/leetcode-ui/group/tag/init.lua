local theme = require("leetcode.theme")

local utils = require("leetcode.parser.utils")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local ts = vim.treesitter

local log = require("leetcode.logger")

---@class lc.ui.Tag : lc.ui.Group
---@field tags string[]
---@field node TSNode
---@field text string
local Tag = Group:extend("LeetTag")

function Tag:get_text(node) return ts.get_node_text(node, self.text) end

---@param node TSNode
function Tag:get_el_data(node)
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

        if ntype == "tag_name" then tag = self:get_text(child) end
    end

    local res = { tag = tag, attrs = attrs }
    return tag and res or nil
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

-- function Tag:draw(layout, opts)
--     Tag.super.draw(self, layout, opts)
--
--     log.info(self._.opts)
-- end

function Tag.normalize(text)
    local norm = text
        :gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("(\n+)(\t+)", "%1")
        -- :gsub("\t*<(/?li)>", "<%1>\n")
        -- :gsub("\t*<(/?ul)>\n*", "<%1>")
        -- :gsub("\t*<(/?ol)>\n*", "<%1>")
        -- :gsub("<(/?pre)>\n*", "<%1>")
        :gsub(
            "<strong>(Input:?%s*)</strong>",
            "<input>%1</input>"
        )
        :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
        :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
        :gsub("<strong>(Follow-up:%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
        :gsub(
            "<p><strong[^>]*>(Example%s*%d*:?)%s*</strong></p>\n*",
            "<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "<p><strong[^>]*>(Constraints:?)%s*</strong></p>\n*",
            "<constraints> %1</constraints>\n\n"
        )
        :gsub("\n*<(img[^>]*)/>\n*", "\n\n<%1>img</img>\n\n")
        -- :gsub("<pre>\n*(.-)\n*</pre>", "<pre>\n%1</pre>")
        :gsub("\n*<pre>", "\n\n<pre>")
        :gsub("\n*<p>&nbsp;</p>\n*", "&lcpad;")
        :gsub("\n", "&lcnl;")
        :gsub("\t", "&lctab;")
        :gsub("%s", "&nbsp;")
        :gsub("<[^>]*>", function(match) return match:gsub("&nbsp;", " ") end)
    -- :gsub("<a[^>]*>(.-)</a>", function(match) return match:gsub("&#?%w+;", utils.entity) end)

    log.debug(text)
    log.debug(norm:gsub("&lcnl;", "&lcnl;\n"), false)

    return norm
end

---@param opts lc.ui.opts
---@param tags string[]
---@param node TSNode
function Tag:init(text, opts, node, tags) --
    Tag.super.init(self, {}, opts or {})

    self.text = text
    self.node = node
    self.tags = tags

    self:parse_helper()
end

---@type fun(text: string, opts: lc.ui.opts, node?: TSNode, tags: string[]): lc.ui.Tag
local LeetTag = Tag

---@param tag lc.ui.Tag
---@param node TSNode
function Tag.static:from(tag, node)
    local t = {
        pre = req_tag("pre"),
        ul = req_tag("ul"),
        ol = req_tag("ol"),
        img = req_tag("img"),
    }

    local el = tag:get_el_data(node) or {}
    local tags = tag.tags

    table.insert(tags, el.tag)
    local opts = { hl = theme.get_dynamic(tags) }
    -- local parsed = (t[tags[#tags]] or LeetTag)(tag.text, opts, tags, node)

    -- local parsed = (LeetTag)(tag.text, opts, node, tags)
    local parsed = (t[tags[#tags]] or LeetTag)(tag.text, opts, node, tags)

    table.remove(tags)

    return parsed
end

---@param text string
function Tag.static:parse(text) --
    text = Tag.normalize(text)

    local ok, parser = pcall(ts.get_string_parser, text, "html")
    assert(ok, parser)
    local root = parser:parse()[1]:root()

    return LeetTag(text, { spacing = 3 }, root, {})
end

return LeetTag
