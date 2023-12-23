local Object = require("nui.object")
local Group = require("leetcode-ui.group")

local Tag = require("leetcode-ui.group.tag")
-- local plain = require("leetcode.parser.plain")
local log = require("leetcode.logger")

---@class lc.Parser
local Parser = Object("LeetParser")

---@param text string
function Parser.normalize(text)
    local norm = text
        :gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("<br />", "\n")
        :gsub("(\n+)(\t+)", "%1")
        :gsub("<(/?li)>\n*", "<%1>\n\n")
        :gsub("\n*(<ul[^>]*>)\n*", "\n\n%1\n")
        :gsub("\n*(<ol[^>]*>)\n*", "\n\n%1\n")
        :gsub("\n*(<pre[^>]*>)", "\n\n%1\n")
        :gsub("<strong>(Input:?%s*)</strong>", "<input>%1</input>")
        :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
        :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
        :gsub("<strong>(Follow-up:%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Note:%s*)</strong>", "<followup>%1</followup>")
        :gsub(
            "\n*<p><strong[^>]*>(Example%s*%d*:?)%s*</strong></p>\n*",
            "\n\n<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "\n*<p><strong[^>]*>(Constraints:?)%s*</strong></p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
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

--- TODO: 2475

---@param text string
---@return lc.ui.Lines
function Parser.static:parse(text)
    local check_for_html = function()
        local parsers = require("nvim-treesitter.parsers")
        assert(parsers.get_parser_configs()["html"])
    end

    text = Parser.normalize(text)

    if pcall(check_for_html) then
        return Tag:parse(text)
    else
        return nil
    end
end

---@type fun(): lc.Parser
local LeetParser = Parser

return LeetParser
