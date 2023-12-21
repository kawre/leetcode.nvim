---TODO: 2659
---TODO: 1404
---TODO: https://leetcode.com/problems/make-array-empty/
---TODO: 190

local utils = require("leetcode.parser.utils")
local log = require("leetcode.logger")

local Tag = require("leetcode-ui.group.tag")

local Object = require("nui.object")

local ts = vim.treesitter

---@class lc.Parser.Html : lc.Parser
local Html = Object("LeetParserHtml")

function Html:get_text(node) return ts.get_node_text(node, self.text) end

---@param node TSNode
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

        if ntype == "tag_name" then tag = self:get_text(child) end
    end

    local res = { tag = tag, attrs = attrs }
    return tag and res or nil
end

function Html:parse_helper() --
    ---@param child TSNode
    for child in self.node:iter_children() do
        local ntype = child:type()

        if ntype == "text" then
            self.curr:append(self:get_text(child))
        elseif ntype == "element" then
            self.curr:append(Html:from(self, child))
        elseif ntype == "entity" then
            local text = self:get_text(child)

            if text == "&lcnl;" then
                self.curr:endl()
            elseif text == "&lcpad;" then
                self.curr:endgrp()
            else
                self.curr:append(utils.entity(text))
            end
        end
    end
end

-- function Html.normalize(text)
--     log.debug(text)
--
--     local xd = text
--         :gsub("​", "")
--         :gsub("\r\n", "\n")
--         :gsub("\t*<(/?li)>", "<%1>")
--         :gsub("\t*<(/?ul)>", "<%1>")
--         :gsub("\t*<(/?ol)>", "<%1>")
--         :gsub("<strong>(Input:?%s*)</strong>", "<input>%1</input>")
--         :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
--         :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
--         :gsub("<strong>(Follow-up:%s*)</strong>", "<followup>%1</followup>")
--         :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
--         :gsub(
--             "<p><strong[^>]*>(Example%s*%d*:?)%s*</strong></p>\n*",
--             "\n\n<example>󰛨 %1</example>\n"
--         )
--         :gsub(
--             "<p><strong[^>]*>(Constraints:?)%s*</strong></p>\n*",
--             "\n<constraints> %1</constraints>\n"
--         )
--         -- :gsub("<(img[^>]*)/>\n*", "<%1>img</img>")
--         -- :gsub("<pre>\n*(.-)\n*</pre>", "<pre>\n%1</pre>")
--         -- :gsub(
--         --     "</([^>]*)>\n*",
--         --     "</%1>"
--         -- )
--         :gsub(
--             "\n*<p>&nbsp;</p>\n*",
--             "&lcpad;"
--         )
--         :gsub("\n", "&lcnl;")
--         :gsub("\t", "&lctab;")
--         :gsub("%s", "&nbsp;")
--         :gsub("<a[^>]*>(.-)</a>", function(match) return match:gsub("&#?%w+;", utils.entity) end)
--         :gsub("<[^>]*>", function(match) return match:gsub("&nbsp;", " ") end)
--
--     log.debug(xd:gsub("&lcnl;", "&lcnl;\n"), false)
--
--     return xd
-- end

function Html.normalize(text)
    local norm = text:gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("\t*<(/?li)>", "<%1>")
        :gsub("\t*<(/?ul)>", "<%1>")
        :gsub("\t*<(/?ol)>", "<%1>")
        :gsub("<strong>(Input:?%s*)</strong>", "<input>%1</input>")
        :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
        :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
        :gsub("<strong>(Follow-up:%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
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
        :gsub("<a[^>]*>(.-)</a>", function(match) return match:gsub("&#?%w+;", utils.entity) end) .. "&lcend;"

    log.debug(text)
    log.debug(norm:gsub("&lcnl;", "&lcnl;\n"), false)

    return norm
end

function Html:init(text, tags, node, curr)
    self.text = text
    self.node = node
    self.curr = curr
    self.tags = tags

    self:parse_helper()
end

---@type fun(text: string, tags: string[], node: TSNode, curr: lc.ui.Tag): lc.Parser.Html
local LeetParserHtml = Html

---@param html lc.Parser.Html
---@param node TSNode
function Html.static:from(html, node)
    local tag = html:get_tag_data(node) or {}

    -- log.debug({
    --     tag = tag.tag,
    --     text = html:get_text(node),
    -- })

    table.insert(html.tags, tag.tag)
    local parsed = LeetParserHtml(html.text, html.tags, node, Tag:from(html.tags, node))
    table.remove(html.tags)

    return parsed.curr
end

---@param text string
function Html.static:parse(text) --
    text = Html.normalize(text)

    local ok, parser = pcall(ts.get_string_parser, text, "html")
    assert(ok, parser)
    local root = parser:parse()[1]:root()

    return LeetParserHtml(text, {}, root, Tag({ spacing = 3 })).curr
end

return LeetParserHtml
