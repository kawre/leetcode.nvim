local utils = require("leetcode.api.utils")
local log = require("leetcode.logger")
local queries = require("leetcode.api.queries")
local problemlist = require("leetcode.cache.problemlist")
local urls = require("leetcode.api.urls")

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
    if not res or err then
        return log.err(err)
    end

    local q = res.data.question
    q.meta_data = select(2, pcall(utils.decode, q.meta_data))
    q.stats = select(2, pcall(utils.decode, q.stats))
    if type(q.similar) == "string" then
        q.similar = utils.normalize_similar_cn(q.similar)
    end

    return q
end

local MAX_FREE_DRAWS = 25

---@param filters? table
local function draw_random(filters)
    local variables = {
        categorySlug = "algorithms",
        filters = filters or vim.empty_dict(),
    }

    local query = queries.random_question

    local config = require("leetcode.config")
    local res, err = utils.query(query, variables)
    if err then
        return nil, err
    end

    local q = res.data.randomQuestion

    if q == vim.NIL then
        local msg = "Random question fetch responded with `null`"

        if filters then
            msg = msg .. ".\n\nMaybe invalid filters?\n" .. vim.inspect(filters)
        end

        return nil, { msg = msg, lvl = vim.log.levels.ERROR }
    end

    if config.is_cn then
        q = {
            title_slug = q,
            paid_only = problemlist.get_by_title_slug(q).paid_only,
        }
    end

    return q
end

---@param filters? table
---@param free_only? boolean redraw until a non-paid question is drawn
function question.random(filters, free_only)
    local q, err = draw_random(filters)

    if free_only then
        for _ = 2, MAX_FREE_DRAWS do
            if err or not q.paid_only then
                return q, err
            end
            q, err = draw_random(filters)
        end
        if err or not q.paid_only then
            return q, err
        end
        return nil,
            {
                msg = ("No free question found after %d draws. Try different filters"):format(
                    MAX_FREE_DRAWS
                ),
                lvl = vim.log.levels.WARN,
            }
    end

    if err then
        return nil, err
    end

    local config = require("leetcode.config")
    if not config.auth.is_premium and q.paid_only then
        return nil,
            {
                msg = "Drawn question is for premium users only. Please try again",
                lvl = vim.log.levels.WARN,
            }
    end

    return q
end

---@param qid integer
---@param lang lc.lang
---@param cb function
function question.latest_submission(qid, lang, cb)
    local url = urls.latest_submission:format(qid, lang)
    utils.get(url, { callback = cb })
end

return question
