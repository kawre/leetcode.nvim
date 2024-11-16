local config = require("leetcode.config")
local Problemlist = require("leetcode.cache.problemlist")
local Companylist = require("leetcode.cache.companylist")

---@class lc.Cache
local cache = {}

function cache.update()
    Problemlist.update()
    if config.auth.is_premium then
        Companylist.update()
    end
end

return cache
