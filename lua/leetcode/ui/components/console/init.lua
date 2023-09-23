---@class lc.Console
local console = {}
console.__index = console

function console:init()
    local obj = setmetatable({}, self)

    return obj
end

return console
