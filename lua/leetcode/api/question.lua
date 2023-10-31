local utils = require("leetcode.api.utils")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")

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

    local query = queries.question()

    local ok, res = pcall(utils.query, query, variables)
    assert(ok)

    local q = res.body.data.question
    q.meta_data = select(2, pcall(utils.decode, q.meta_data))
    q.stats = select(2, pcall(utils.decode, q.stats))
    if type(q.similar) == "string" then q.similar = utils.normalize_similar_cn(q.similar) end

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
    local ok, res = pcall(utils.query, query, variables)
    assert(ok, res)

    local q = res.body.data.randomQuestion
    if not config.auth.is_premium and q.paid_only then
        log.warn("Drawn question is for premium users only. Please try again")
        return
    end

    return q
end

return question
