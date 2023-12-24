local Normalizer = require("leetcode.parser.normalizer")
local u = require("leetcode.parser.utils")

function Normalizer:cleanup()
    self.text = self
        .text --
        :gsub("​", "")
        :gsub("\r\n", "\n")
        :gsub("<br%s*/>", "\n")
        :gsub("<meta[^>]*/>", "")
        :gsub("&nbsp;", " ")
        :gsub("<(/?)b([^>]*)>", "<%1strong%2>")
        :gsub(":", "：")
    -- :gsub("<=", "&le;")
    -- :gsub(">", "&le;")
    -- :gsub("<", "&le;")
    -- :gsub("> =", "&le;")

    -- for e, char in pairs(u.entities) do
    --     self.text = self.text:gsub(e, char)
    -- end
end

function Normalizer:tags() --
    self.text = self
        .text --
        :gsub("<strong>(输入：?%s*)</strong>", "<input>%1</input>") -- input
        :gsub("<strong>(输出：?%s*)</strong>", "<output>%1</output>") -- output
        :gsub("<strong>(解释：?%s*)</strong>", "<explanation>%1</explanation>") -- explanation
        :gsub("<strong>(进阶：?%s*)</strong>", "<followup>%1</followup>") -- Note
        -- :gsub("<strong>(提示：%s*)</strong>", "<followup>%1</followup>") -- Note
        :gsub(
            "<strong>(注意：%s*)</strong>",
            "<followup>%1</followup>"
        ) -- Followup
        :gsub(
            "\n*<p><strong[^>]*>(示例%s*%d*：?)%s*</strong></p>\n*",
            "\n\n<example>󰛨 %1</example>\n\n"
        )
        :gsub(
            "\n*<p><strong[^>]*>(提示：?)%s*</strong></p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
        )
        :gsub(
            "\n*<p><strong[^>]*>(限制：?)%s*</strong></p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
        )
        :gsub(
            "\n*<p>%s*<strong[^>]*>(提示：?)%s*</strong>%s*</p>\n*",
            "\n\n<constraints> %1</constraints>\n\n"
        )
end
