local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")
local Line = require("nui.line")

---@class lc-ui.Padding: lc-ui.Component
local padding = {}
padding.__index = padding
setmetatable(padding, component)

--------------------------------------------------------
--- Methods
--------------------------------------------------------

--------------------------------------------------------
--- Constructor
--------------------------------------------------------

---@param int integer
---
---@return lc-ui.Component
function padding:init(int)
    local t = {}
    for _ = 1, int, 1 do
        table.insert(t, Line())
    end

    return setmetatable({ lines = t, opts = {} }, self)
end

return padding
