---@class leet.api
---@field problems lc.ProblemsApi

return setmetatable({}, {
    __index = function(_, key)
        return require("leetcode.api." .. key)
    end,
})
