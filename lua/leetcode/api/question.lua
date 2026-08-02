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

---@param filters? table
function question.random(filters)
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

    if not config.auth.is_premium and q.paid_only then
        err = err or {}
        err.msg = "Drawn question is for premium users only. Please try again"
        err.lvl = vim.log.levels.WARN
        return nil, err
    end

    return q
end

---@class lc.editorial_res
---@field uuid string
---@field title string
---@field slug string
---@field is_serialized boolean
---@field has_video boolean
---@field content string

---Fetch the official solution (editorial) article for a problem.
---
---@param title_slug string
---
---@return lc.editorial_res|nil, lc.err|nil
function question.editorial(title_slug)
    local variables = {
        questionSlug = title_slug,
    }

    local res, err = utils.query(queries.editorial, variables)
    if err then
        return nil, err
    end

    -- Guard the whole response shape: a GraphQL error envelope (or a restricted
    -- response) can arrive with `data` missing/null, so never index it blindly.
    local article = type(res) == "table"
        and type(res.data) == "table"
        and res.data.ugcArticleOfficialSolutionArticle
    if not article or article == vim.NIL or type(article) ~= "table" then
        return nil, { msg = "No editorial available for this problem", lvl = vim.log.levels.WARN }
    end

    -- `content` is the only field the UI hard-depends on; a null one (premium
    -- teaser, unpublished article) is treated the same as no editorial.
    if type(article.content) ~= "string" or article.content == "" then
        return nil, { msg = "No editorial available for this problem", lvl = vim.log.levels.WARN }
    end

    return article
end

---@class lc.playground_code
---@field code string
---@field lang_slug string

---Fetch the code samples backing a shared playground (editorial `<iframe>`s).
---
---@param uuid string
---
---@return lc.playground_code[], lc.err|nil
function question.playground(uuid)
    if type(uuid) ~= "string" or uuid == "" then
        return {}
    end

    local res, err = utils.query(queries.playground, { uuid = uuid })
    if err then
        return {}, err
    end

    -- Same defensive shape check as `editorial`: tolerate a missing/null `data`.
    local codes = type(res) == "table"
        and type(res.data) == "table"
        and res.data.all_playground_codes
    if type(codes) ~= "table" or codes == vim.NIL then
        return {}
    end

    -- Keep only well-formed entries so the UI can trust `code`/`lang_slug`.
    local valid = {}
    for _, c in ipairs(codes) do
        if type(c) == "table" and type(c.code) == "string" then
            valid[#valid + 1] = c
        end
    end
    return valid
end

---@param qid integer
---@param lang lc.lang
---@param cb function
function question.latest_submission(qid, lang, cb)
    local url = urls.latest_submission:format(qid, lang)
    utils.get(url, { callback = cb })
end

return question
