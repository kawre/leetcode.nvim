local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local log = require("leetcode.logger")

---@class lc.ProblemsApi
local M = {}

---@return lc.Cache.Question[]
function M.all(cb)
    local variables = {
        limit = 9999,
    }

    local query = queries.problemset()

    if cb then
        utils.query(query, variables, function(res, err)
            local data = res.data
            local questions = data["problemsetQuestionList"]["questions"]
            cb(utils.normalize_cn_problemlist(questions))
        end)
    else
        local res, err = utils.query(query, variables)
        local questions = res.data["problemsetQuestionList"]["questions"]
        return utils.normalize_cn_problemlist(questions)
    end
end

function M.question_of_today(cb)
    local query = queries.qot()

    local callback = function(res)
        local question = res.data["activeDailyCodingChallengeQuestion"]["question"]
        cb(question)
    end

    utils.query(query, {}, callback)
end

return M
