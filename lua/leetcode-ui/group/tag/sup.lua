local Tag = require("leetcode-ui.group.tag")
local Line = require("leetcode-ui.line")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sup : lc.ui.Tag
local Sup = Tag:extend("LeetTagSup")

local superscript = {
    ["0"] = "⁰",
    ["1"] = "¹",
    ["2"] = "²",
    ["3"] = "³",
    ["4"] = "⁴",
    ["5"] = "⁵",
    ["6"] = "⁶",
    ["7"] = "⁷",
    ["8"] = "⁸",
    ["9"] = "⁹",
    ["a"] = "ᵃ",
    ["b"] = "ᵇ",
    ["c"] = "ᶜ",
    ["d"] = "ᵈ",
    ["e"] = "ᵉ",
    ["f"] = "ᶠ",
    ["g"] = "ᵍ",
    ["h"] = "ʰ",
    ["i"] = "ⁱ",
    ["j"] = "ʲ",
    ["k"] = "ᵏ",
    ["l"] = "ˡ",
    ["m"] = "ᵐ",
    ["n"] = "ⁿ",
    ["o"] = "ᵒ",
    ["p"] = "ᵖ",
    ["q"] = "ᵠ",
    ["r"] = "ʳ",
    ["s"] = "ˢ",
    ["t"] = "ᵗ",
    ["u"] = "ᵘ",
    ["v"] = "ᵛ",
    ["w"] = "ʷ",
    ["x"] = "ˣ",
    ["y"] = "ʸ",
    ["z"] = "ᶻ",
}

-- function Sup:append(content, highlight)
--     content = content:gsub(".", function(match) return superscript[match:lower()] or match end)
--
--     Sup.super.append(self, content, highlight)
-- end

function Sup:parse_node()
    self:append("^")

    Sup.super.parse_node(self)
end

---@type fun(): lc.ui.Tag.sup
local LeetTagSup = Sup

return LeetTagSup
