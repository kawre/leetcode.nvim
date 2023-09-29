local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")

---@class lc-ui.Text: lc-ui.Component
local text = {}
text.__index = text
setmetatable(text, component)

--------------------------------------------------------
--- Methods
--------------------------------------------------------

--------------------------------------------------------
--- Constructor
--------------------------------------------------------

---@param config? lc-ui.Component.config
---
---@return lc-ui.Text
function text:init(config)
    config = config or {}
    local obj = {
        lines = utils.parse_lines(config),
        opts = config.opts or {},
    }

    return setmetatable(obj, self)
end

return text
