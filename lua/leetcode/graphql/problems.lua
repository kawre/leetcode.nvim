local logger = require("leetcode.logger")
local gql = require("leetcode.graphql.utils")

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

  local total = gql.query(query)["problemsetQuestionList"]["total"]

  return total
end

---@return lc.Problem[]
function M.all()
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
          index: questionFrontendId
          title
          title_slug: titleSlug
          ac_rate: acRate
          difficulty
        }
      }
    }
  ]]

  local ok, res = pcall(gql.query, query, variables)
  assert(ok)

  return res["problemsetQuestionList"]["questions"]
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

  local ok, res = pcall(gql.query, query)
  assert(ok)

  logger.inspect(res)

  return res["activeDailyCodingChallengeQuestion"]
end

return M
