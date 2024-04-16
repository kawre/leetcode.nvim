local Problemlist = require("leetcode.cache.problemlist")
local Companylist = require("leetcode.cache.companylist")

---@class lc.Cache
local cache = {}

function cache.update()
    Problemlist.update()
    Companylist.update()
end

return cache
