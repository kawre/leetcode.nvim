local gql = require("leetcode.graphql.utils")
local log = require("leetcode.logger")

local M = {}

---@class lc.Question.Content
---@field content string

---@param title_slug string
---
---@return lc.Question.Content
function M.content(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = [[
    query questionContent($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        content
        mysqlSchemas
        dataSchemas
      }
    }
  ]]

    local ok, res = pcall(gql.query, query, variables)
    assert(ok)

    return res["question"]
end

---@param title_slug string
function M.editor_data(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = [[
    query questionEditorData($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        questionId
        questionFrontendId
        code_snippets: codeSnippets {
          lang
          langSlug
          code
        }
        envInfo
        enableRunCode
        hasFrontendPreview
        frontendPreviews
      }
    }
  ]]

    local ok, res = pcall(gql.query, query, variables)
    assert(ok)

    return res["question"]
end

---@param title_slug string
function M.title(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = [[
    query questionTitle($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        questionId
        questionFrontendId
        title
        titleSlug
        isPaidOnly
        difficulty
        likes
        dislikes
        categoryTitle
      }
    }
  ]]

    return gql.query(query, variables)["question"]
end

return M
