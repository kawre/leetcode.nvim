local NuiText = require("nui.text")
local Lines = require("leetcode-ui.lines")

local log = require("leetcode.logger")

---@class lc.Result.Pre : lc-ui.Lines
local Pre = Lines:extend("LeetPre")

function Pre:add_margin(item)
    if item.class.name == "LeetLine" then
        table.insert(item._texts, 1, NuiText("\t▎\t", "leetcode_indent"))
        return
    end

    for _, c in ipairs(item:contents()) do
        self:add_margin(c)
    end
end

---@param title? lc.ui.Line
---@param item lc-ui.Lines
---
---@return lc-ui.Lines
function Pre:init(title, item)
    Pre.super.init(self)

    if title then --
        self:append(title):endl():endl()
    end

    if item then
        self:add_margin(item)
        self:insert(item)
    end
end

---@alias Pre.constructor fun(title: lc.ui.Line, lines: any): lc.Result.Pre
---@type Pre.constructor
local LeetPre = Pre

return LeetPre
