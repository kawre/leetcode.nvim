local utils = require("leetcode.api.utils")
local log = require("leetcode.logger")

local question = {}

---@class lc.Question.Content
---@field content string

---@param title_slug string
---
---@return lc.question_res
function question.by_title_slug(title_slug)
    utils.auth_guard()

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
            ac_rate: acRate
            stats
            hints
            topic_tags: topicTags {
                name
                slug
            }
            similar: similarQuestionList {
              difficulty
              title_slug: titleSlug
              title
              paid_only: isPaidOnly
            }
          }
        }
    ]]

    local res, err = utils.query(query, variables)

    local q = res.data.question
    q.meta_data = select(2, pcall(utils.decode, q.meta_data))
    q.stats = select(2, pcall(utils.decode, q.stats))

    return q
end

function question.random()
    local variables = {
        categorySlug = "",
    }

    local query = [[
      query randomQuestion($categorySlug: String) {
        randomQuestion(categorySlug: $categorySlug, filters: {}) {
          title_slug: titleSlug
          paid_only: isPaidOnly
        }
      }
    ]]

    local config = require("leetcode.config")
    local res, err = utils.query(query, variables)

    local q = res.data.randomQuestion
    if not config.auth.is_premium and q.paid_only then
        log.warn("Drawn question is for premium users only. Please try again")
        return
    end

    return q
end

return question
