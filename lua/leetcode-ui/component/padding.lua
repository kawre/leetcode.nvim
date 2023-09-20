local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")
local Line = require("nui.line")

---@class lc.db.Padding: lc.db.Component
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
---@return lc.db.Component
function padding:init(int)
    local t = {}
    for _ = 1, int, 1 do
        table.insert(t, Line():append(""))
    end

    local o = setmetatable({ lines = t, opts = {} }, self)
    self.__index = self
    self.lines = t
    self.opts = {}

    return o
end

return padding
