local Problemlist = require("leetcode.cache.problems")

---@class leet.cache
---@field cookie leet.cache.cookie
---@field problems leet.cache.problems
local M = setmetatable({}, {
    __index = function(t, k)
        t[k] = require("leetcode.cache." .. k)
        return rawget(t, k)
    end,
})

function M.update()
    Problemlist.update()
end

return M
