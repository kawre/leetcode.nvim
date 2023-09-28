local log = require("leetcode.logger")
local utils = require("leetcode.api.utils")

---@class lc.ProblemsApi
local M = {}

---@return lc.Problem[]
function M.all()
    assert(utils.auth_guard(), "User not signed in")

    local variables = {
        limit = 9999,
    }

    local query = [[
        query problemsetQuestionList($limit: Int) {
          problemsetQuestionList: questionList(
              categorySlug: ""
              limit: $limit
              filters: {}
          ) {
            questions: data {
              frontend_id: questionFrontendId
              title
              title_slug: titleSlug
              status
              paid_only: isPaidOnly
              ac_rate: acRate
              difficulty
            }
          }
        }
    ]]

    local ok, res = pcall(utils.query, query, variables)
    assert(ok)

    return res["problemsetQuestionList"]["questions"]
end

---@param cb function
---
---@return lc.Problem[]
function M._all(cb)
    local variables = {
        limit = 3000,
    }

    local query = [[
        query problemsetQuestionList($limit: Int) {
          problemsetQuestionList: questionList(
              categorySlug: ""
              limit: $limit
              filters: {}
          ) {
            questions: data {
              frontend_id: questionFrontendId
              title
              title_slug: titleSlug
              status
              paid_only: isPaidOnly
              ac_rate: acRate
              difficulty
            }
          }
        }
    ]]

    local callback = function(res)
        local ok, body = pcall(vim.json.decode, res["body"])
        if not ok then return log.error("failed to decode problem list response body") end
        assert(body)

        local data = body["data"]["problemsetQuestionList"]["questions"]
        cb(data)
    end

    utils._query({
        query = query,
        variables = variables,
    }, callback)
end

function M.question_of_today()
    utils.auth_guard()

    local query = [[
        query questionOfToday {
          activeDailyCodingChallengeQuestion {
            userStatus
            link
            question {
              acRate
              difficulty
              freqBar
              index: questionFrontendId
              isFavor
              paidOnly: isPaidOnly
              status
              title
              titleSlug
            }
          }
        }
      ]]

    local ok, res = pcall(utils.query, query)
    assert(ok)

    return res["activeDailyCodingChallengeQuestion"]
end

return M
