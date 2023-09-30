local cookie = require("leetcode.cache.cookie")
local problems = require("leetcode.cache.problems")

---@class lc.Cache
local cache = {}

function cache.update()
    -- log.info(2)
    problems.update(true)
    -- cookie.update()
end

return cache
