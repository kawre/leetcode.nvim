local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.sub : lc.ui.Tag
local Sub = Tag:extend("LeetTagSub")

local subscript = {
    ["0"] = "₀",
    ["1"] = "₁",
    ["2"] = "₂",
    ["3"] = "₃",
    ["4"] = "₄",
    ["5"] = "₅",
    ["6"] = "₆",
    ["7"] = "₇",
    ["8"] = "₈",
    ["9"] = "₉",
    ["a"] = "ₐ",
    ["b"] = "♭",
    ["c"] = "꜀",
    ["d"] = "ᑯ",
    ["e"] = "ₑ",
    ["f"] = "բ",
    ["g"] = "₉",
    ["h"] = "ₕ",
    ["i"] = "ᵢ",
    ["j"] = "ⱼ",
    ["k"] = "ₖ",
    ["l"] = "ₗ",
    ["m"] = "ₘ",
    ["n"] = "ₙ",
    ["o"] = "ₒ",
    ["p"] = "ₚ",
    ["q"] = "ɋ",
    ["r"] = "ᵣ",
    ["s"] = "ₛ",
    ["t"] = "ₜ",
    ["u"] = "ᵤ",
    ["v"] = "ᵥ",
    ["w"] = "w",
    ["x"] = "ₓ",
    ["y"] = "y",
    ["z"] = "z",
}

-- function Sub:append(content, highlight)
--     content = content:gsub(".", function(match) return subscript[match:lower()] or match end)
--
--     Sub.super.append(self, content, highlight)
-- end

function Sub:parse_node()
    self:append("_")

    Sub.super.parse_node(self)
end

---@type fun(): lc.ui.Tag.sub
local LeetTagSub = Sub

return LeetTagSub
