local log = require("leetcode.logger")

---@class lc-menu.Solved
local Solved = {}
Solved.__index = Solved

function Solved:init()
    self = setmetatable({}, self)

    log.info("siema")

    return self
end

return Solved
