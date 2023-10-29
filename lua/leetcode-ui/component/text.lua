local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")

---@class lc-ui.Text: lc-ui.Component
local Text = {}
Text.__index = Text
setmetatable(Text, component)

---@param lines NuiLine[] | string[]
---@param opts? lc-ui.Component.opts
---
---@return lc-ui.Text
function Text:init(lines, opts)
    opts = opts or {}
    lines = lines or {}

    return setmetatable({
        lines = utils.parse_lines(lines, opts),
        opts = opts,
    }, self)
end

return Text
