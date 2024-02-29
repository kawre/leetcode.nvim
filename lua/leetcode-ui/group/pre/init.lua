local NuiText = require("nui.text")
local Group = require("leetcode-ui.group")
local config = require("leetcode.config")

local log = require("leetcode.logger")

---@class lc.ui.Pre : lc.ui.Group
local Pre = Group:extend("LeetPre")

function Pre:add_margin(item)
    if item.class.name == "LeetLine" then
        table.insert(item._texts, 1, NuiText(config.icons.indent, "leetcode_indent"))
        return
    end

    for _, c in ipairs(item:contents()) do
        self:add_margin(c)
    end
end

---@param title? lc.ui.Line
---@param item lc.ui.Lines
function Pre:init(title, item)
    Pre.super.init(self, {}, { spacing = 1, position = "left" })

    if title then
        self:insert(title)
    end

    if item then
        self:add_margin(item)
        self:insert(item)
    end
end

---@alias Pre.constructor fun(title: lc.ui.Line, lines: any): lc.ui.Pre
---@type Pre.constructor
local LeetPre = Pre

return LeetPre
