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
    topic_tags: topicTags {
        name
        slug
        id
    }
]]

---@return lc.Cache.Question[]
function M.all(cb)
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

    if cb then
        utils.query(query, variables, function(res)
            local data = res.data
            local questions = data["problemsetQuestionList"]["questions"]
            cb(questions)
        end)
    else
        local res, err = utils.query(query, variables)
        local data = res.data
        return data["problemsetQuestionList"]["questions"]
    end
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

    local callback = function(res)
        local question = res.data["activeDailyCodingChallengeQuestion"]["question"]
        cb(question)
    end

    utils.query(query, {}, callback)
end

return M
