local Object = require("nui.object")
local u = require("leetcode.parser.utils")

local log = require("leetcode.logger")

---@class lc.Normalizer
local Normalizer = Object("LeetNormalizer")

function Normalizer:cleanup() --
    self.text = self
        .text --
        :gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("<br%s*/>", "\n")
        :gsub("<meta[^>]*/>", "")
        :gsub("&nbsp;", " ")
        -- :gsub("<(/?)b([^>]*)>", "<%1strong%2>")
        :gsub("<(/?)b>", "<%1strong>")
    -- :gsub("&#?%w+;", function(e) --
    --     return vim.tbl_keys({})
    -- end)

    -- for e, char in pairs(u.entities) do
    --     self.text = self.text:gsub(e, char)
    -- end
end

function Normalizer:fix_indent()
    self.text = self
        .text --
        :gsub("(\n+)(\t+)", "%1")
        :gsub("<(/?li)>\n*", "<%1>\n\n")
        :gsub("\n*(<ul[^>]*>)\n*", "\n\n%1\n")
        :gsub("\n*(<ol[^>]*>)\n*", "\n\n%1\n")
        :gsub("\n*(<pre[^>]*>)", "\n\n%1\n")
        :gsub("\n*(<img[^>]*/?>)\n*", "\n\n%1\n\n")
end

function Normalizer:tags() --
    self.text = self
        .text --
        :gsub("<strong>(Input:?%s*)</strong>", "<input>%1</input>")
        :gsub("<strong>(Output:?%s*)</strong>", "<output>%1</output>")
        :gsub("<strong>(Explanation:?%s*)</strong>", "<explanation>%1</explanation>")
        :gsub("<strong>(Note:?%s*)</strong>", "<explanation>%1</explanation>")
        :gsub("<strong>(Follow-up:?%s*)</strong>", "<followup>%1</followup>")
        :gsub("<strong>(Follow up:?%s*)</strong>", "<followup>%1</followup>")
        :gsub(
            "\n*<p>%s*<strong[^>]*>(Example%s*%d*:?)%s*</strong>%s*</p>\n*",
            "\n\n<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "\n*<p>%s*<strong[^>]*>(Constraints:?)%s*</strong>%s*</p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
        )
end

function Normalizer:entities()
    self.text = self
        .text --
        :gsub("\n*<p>%s*</p>\n*", "&lcpad;")
        :gsub("\n*<p> *</p>\n*", "&lcpad;")
        :gsub("<([^>]+)>(%s*)</%1>", "%2")
        :gsub("\n", "&lcnl;")
        :gsub("\t", "&lctab;")
        :gsub("%s", "&nbsp;")
        :gsub("<[^>]+>", function(match)
            return match:gsub("&nbsp;", " ")
        end)
end

---@param text string
function Normalizer:init(text) --
    log.debug(text)

    self.text = text
    self:cleanup()
    self:fix_indent()
    self:tags()
    self:entities()

    log.debug(self.text:gsub("&lcnl;", "\n"), false)
end

---@type fun(text: string): lc.Normalizer
local LeetNormalizer = Normalizer

---@param text string
function Normalizer:norm(text)
    return LeetNormalizer(text).text
end

return LeetNormalizer
