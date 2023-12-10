local utils = require("leetcode.api.utils")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")
local problemlist = require("leetcode.cache.problemlist")

local question = {}

---@class lc.Question.Content
---@field content string

---@param title_slug string
---
---@return lc.question_res|nil
function question.by_title_slug(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = queries.question

    local res, err = utils.query(query, variables)
    if not res or err then return log.err(err) end

    local q = res.data.question
    q.meta_data = select(2, pcall(utils.decode, q.meta_data))
    q.stats = select(2, pcall(utils.decode, q.stats))
    if type(q.similar) == "string" then q.similar = utils.normalize_similar_cn(q.similar) end

    return q
end

function question.random()
    local variables = {
        categorySlug = "algorithms",
    }

    local query = queries.random_question

    local config = require("leetcode.config")
    repeat
        local res, err = utils.query(query, variables)
        if err then return nil, err end

        local q = res.data.randomQuestion
        if config.is_cn then
            q = {
                title_slug = q,
                paid_only = problemlist.get_by_title_slug(q).paid_only,
            }
        end

        if not config.auth.is_premium and q.paid_only then
            vim.notify("Drawn question is for premium users only. Reattempting to get another question.")
        else
            return q
        end
    until false
end

return question
