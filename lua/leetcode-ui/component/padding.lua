local component = require("leetcode-ui.component")
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
    local tbl = {}
    for _ = 1, int, 1 do
        table.insert(tbl, Line())
    end

    return setmetatable({ lines = tbl, opts = {} }, self)
end

return padding
