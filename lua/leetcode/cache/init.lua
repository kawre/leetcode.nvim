local cookie = require("leetcode.cache.cookie")
local problems = require("leetcode.cache.problems")

---@class lc.Cache
local cache = {}

cache.cookie = {}

cache.problems = {}

function cache.setup()
    cache.cookie = cookie.get()
    cache.problems = problems.get()

    return cache
end

function cache.update()
    problems.update(true)
    -- cookie.update()
end

return cache
