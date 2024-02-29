local Problemlist = require("leetcode.cache.problemlist")

---@class lc.Cache
local cache = {}

function cache.update()
    Problemlist.update()
end

return cache
