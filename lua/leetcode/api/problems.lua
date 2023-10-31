local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local log = require("leetcode.logger")

---@class lc.ProblemsApi
local M = {}

---@return lc.Cache.Question[]
function M.all()
    utils.auth_guard()

    local variables = {
        limit = 9999,
    }

    local query = queries.problemset()

    local ok, res = pcall(utils.query, query, variables)
    assert(ok, res)

    local data = res.body.data
    return utils.normalize_cn_problemlist(data["problemsetQuestionList"]["questions"])
end

---@param cb function
---
---@return lc.Cache.Question[]
function M._all(cb)
    local variables = {
        limit = 9999,
    }

    local query = queries.problemset()

    local callback = function(res)
        local data = res.body.data
        local questions = data["problemsetQuestionList"]["questions"]
        cb(utils.normalize_cn_problemlist(questions))
    end

    utils._query(query, variables, callback)
end

function M.question_of_today(cb)
    utils.auth_guard()

    local query = queries.qot()

    local callback = function(res)
        local question = res.body.data["activeDailyCodingChallengeQuestion"]["question"]
        cb(question)
    end

    utils._query(query, {}, callback)
end

return M
