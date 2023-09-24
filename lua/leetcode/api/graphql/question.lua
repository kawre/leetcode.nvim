local utils = require("leetcode.api.graphql.utils")
local log = require("leetcode.logger")

local question = {}

---@class lc.Question.Content
---@field content string

---@param title_slug string
---
---@return question_response
function question.by_title_slug(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = [[
        query ($titleSlug: String!) {
          question(titleSlug: $titleSlug) {
            id:  questionId
            frontend_id: questionFrontendId
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
            meta_data: metaData
          }
        }
    ]]

    local ok, res = pcall(utils.query, query, variables)
    assert(ok)
    local md = res["question"].meta_data
    local dok, decoded = pcall(vim.json.decode, md)
    if dok then res["question"].meta_data = decoded end

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

    return utils.query(query, variables)["randomQuestion"]
end

return question
