local gql = require("leetcode.graphql.utils")
local logger = require("leetcode.logger")

local M = {}

---@param title_slug string
function M.get_by_title_slug(title_slug)
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

  logger.inspect(res)

  return res["questionContent"]
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

return M
