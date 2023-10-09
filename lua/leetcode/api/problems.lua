local utils = require("leetcode.api.utils")

---@class lc.ProblemsApi
local M = {}

local question_fields = [[ 
    frontend_id: questionFrontendId
    title
    title_slug: titleSlug
    status
    paid_only: isPaidOnly
    ac_rate: acRate
    difficulty
]]

---@return lc.Cache.Question[]
function M.all()
    utils.auth_guard()

    local variables = {
        limit = 9999,
    }

    local query = string.format(
        [[
            query problemsetQuestionList($limit: Int) {
              problemsetQuestionList: questionList(
                  categorySlug: ""
                  limit: $limit
                  filters: {}
              ) {
                questions: data { %s }
              }
            }
        ]],
        question_fields
    )

    local ok, res = pcall(utils.query, query, variables)
    assert(ok)

    return res["problemsetQuestionList"]["questions"]
end

---@param cb function
---
---@return lc.Cache.Question[]
function M._all(cb)
    local variables = {
        limit = 3000,
    }

    local query = string.format(
        [[
            query problemsetQuestionList($limit: Int) {
              problemsetQuestionList: questionList(
                  categorySlug: ""
                  limit: $limit
                  filters: {}
              ) {
                questions: data { %s }
              }
            }
        ]],
        question_fields
    )

    local callback = function(res)
        local data = res["problemsetQuestionList"]["questions"]
        cb(data)
    end

    utils._query({
        query = query,
        variables = variables,
    }, callback)
end

function M.question_of_today(cb)
    utils.auth_guard()

    local query = string.format(
        [[
            query questionOfToday {
              activeDailyCodingChallengeQuestion {
                userStatus
                link
                question { %s }
              }
            }
        ]],
        question_fields
    )

    local callback = function(res) cb(res["activeDailyCodingChallengeQuestion"]["question"]) end

    utils._query({ query = query }, callback)
end

return M
