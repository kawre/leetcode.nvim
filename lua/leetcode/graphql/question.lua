local gql = require("leetcode.graphql.utils")
local log = require("leetcode.logger")

local question = {}

---@class lc.Question.Content
---@field content string

-- ---@param title_slug string
-- ---
-- ---@return lc.Question.Content
-- function question.content(title_slug)
--     local variables = {
--         titleSlug = title_slug,
--     }
--
--     local query = [[
--     query questionContent($titleSlug: String!) {
--       question(titleSlug: $titleSlug) {
--         content
--         mysqlSchemas
--         dataSchemas
--       }
--     }
--   ]]
--
--     local ok, res = pcall(gql.query, query, variables)
--     assert(ok)
--
--     return res["question"]
-- end

---@param title_slug string
---
---@return lc.QuestionResponse
function question.by_title_slug(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = [[
        query ($titleSlug: String!) {
          question(titleSlug: $titleSlug) {
            question_id:  questionId
            question_frontend_id: questionFrontendId
            title
            title_slug: titleSlug
            is_paid_only: isPaidOnly
            difficulty
            likes
            dislikes
            category_title: categoryTitle
            content
            mysql_schemas: mysqlSchemas
            data_schemas: dataSchemas
            code_snippets: codeSnippets {
              lang
              lang_slug: langSlug
              code
            }
            testcase_list: exampleTestcaseList
          }
        }
    ]]

    local ok, res = pcall(gql.query, query, variables)
    assert(ok)

    return res["question"]
end

function question.random()
    local variables = {
        categorySlug = "",
    }

    local query = [[
      query randomQuestion($categorySlug: String) {
        randomQuestion(categorySlug: $categorySlug, filters: {}) {
          title_slug: titleSlug
        }
      }
    ]]

    return gql.query(query, variables)["randomQuestion"]
end

return question
