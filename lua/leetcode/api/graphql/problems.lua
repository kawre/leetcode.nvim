local log = require("leetcode.logger")
local utils = require("leetcode.api.graphql.utils")

---@class lc.ProblemsApi
local M = {}

---@return integer
function M.total_num()
    local query = [[
        query problemsetQuestionList {
          problemsetQuestionList: questionList(
            categorySlug: ""
            filters: {}
          ) {
            total: totalNum
            }
        }
    ]]

    local total = utils.query(query)["problemsetQuestionList"]["total"]

    return total
end

---@return lc.Problem[]
function M.all()
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
