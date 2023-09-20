local component = require("leetcode-ui.component")
local utils = require("leetcode-ui.utils")

---@class lc.db.Text: lc.db.Component
local text = {}
text.__index = text
setmetatable(text, component)

--------------------------------------------------------
--- Methods
--------------------------------------------------------

--------------------------------------------------------
--- Constructor
--------------------------------------------------------

---@param config lc.db.Component.config
---
---@return lc.db.Text
function text:init(config)
    local parsed_lines = utils.parse_lines(config)
    config.lines = parsed_lines

    local o = setmetatable(config, self)
    self.__index = self

    self.lines = parsed_lines
    self.opts = config.opts or {}

    return o
end

return text
