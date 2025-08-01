local queries = require("leetcode.api.queries")
local config = require("leetcode.config")
local urls = require("leetcode.api.urls")
local Spinner = require("leetcode.logger.spinner")

---@class leet.api.problems
local M = {}

---@param cb? function
---@param noti? boolean
---
---@return lc.cache.Question[], lc.err
function M.all(cb, noti)
    local endpoint = urls.problems:format("algorithms")

    local spinner
    if noti then
        spinner = Spinner:start("updating problemlist cache", "points")
    end

    if cb then
        Leet.api.get(endpoint, {
            callback = function(res, err)
                if err then
                    if spinner then
                        spinner:error(err.msg)
                    end
                    return cb(nil, err)
                end

                local problems = Leet.api.problems.normalize(res.stat_status_pairs)

                if config.is_cn then
                    if spinner then
                        spinner:update("fetching title translations")
                    end
                    M.translated_titles(function(titles, terr)
                        if terr then
                            if spinner then
                                spinner:error(terr.msg)
                            end
                            return cb(nil, terr)
                        end

                        problems = Leet.api.translate_titles(problems, titles)
                        if spinner then
                            spinner:success("cache updated")
                        end

                        cb(problems)
                    end)
                else
                    if spinner then
                        spinner:success("cache updated")
                    end

                    cb(problems)
                end
            end,
        })
    else
        local res, err = Leet.api.get(endpoint)
        if err then
            if spinner then
                spinner:error(err.msg)
            end
            return nil, err
        end

        local problems = Leet.api.problems.normalize(res.stat_status_pairs)

        if config.is_cn then
            local titles, terr = M.translated_titles()
            if terr then
                if spinner then
                    spinner:error(terr.msg)
                end
                return nil, terr
            end

            if spinner then
                spinner:success("problems cache updated")
            end
            return Leet.api.translate_titles(problems, titles)
        else
            if spinner then
                spinner:success("problems cache updated")
            end
            return problems
        end
    end
end

function M.question_of_today(cb)
    local query = queries.qot

    Leet.api.query(query, {}, {
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local tday_record = res.data["todayRecord"]
            local question = config.is_cn and tday_record[1].question or tday_record.question
            cb(question)
        end,
    })
end

function M.translated_titles(cb)
    local query = queries.translations

    if cb then
        Leet.api.query(query, {}, {
            callback = function(res, err)
                if err then
                    return cb(nil, err)
                end
                cb(res.data.translations)
            end,
        })
    else
        local res, err = utils.query(query, {})
        if err then
            return nil, err
        end
        return res.data.translations
    end
end

---@param filters? table
function M.random(filters)
    local variables = {
        categorySlug = "algorithms",
        filters = filters or vim.empty_dict(),
    }

    local query = queries.random_question

    local res, err = Leet.api.query(query, variables)
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
            paid_only = Leet.cache.problems.by_slug(q).paid_only,
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

---@param qid integer
---@param lang lc.lang
---@param cb function
function M.latest_submission(qid, lang, cb)
    local url = urls.latest_submission:format(qid, lang)
    Leet.api.get(url, { callback = cb })
end

---@param title_slug string
---
---@return lc.question_res|nil
function M.by_title_slug(title_slug)
    local variables = {
        titleSlug = title_slug,
    }

    local query = queries.question

    local res, err = Leet.api.query(query, variables)
    if not res or err then
        return log.err(err)
    end

    local q = res.data.question
    q.meta_data = vim.json.decode(q.meta_data)
    q.stats = vim.json.decode(q.stats)
    if type(q.similar) == "string" then
        q.similar = Leet.api.normalize_similar_cn(q.similar)
    end

    return q
end

---@return lc.cache.Question[]
function M.normalize(problems)
    problems = vim.tbl_filter(function(p)
        return not p.stat.question__hide
    end, problems)

    local comp = function(a, b)
        local a_fid = a.stat.frontend_question_id
        local b_fid = b.stat.frontend_question_id

        local is_num_a = tonumber(a_fid)
        local is_num_b = tonumber(b_fid)

        if is_num_a and is_num_b then
            return tonumber(a_fid) < tonumber(b_fid)
        elseif is_num_a then
            return true
        elseif is_num_b then
            return false
        else
            return a_fid < b_fid
        end
    end
    table.sort(problems, comp)

    return vim.tbl_map(function(p)
        return {
            status = p.status == vim.NIL and "todo" or p.status, -- api returns nil for todo
            id = p.stat.question_id,
            frontend_id = p.stat.frontend_question_id,
            title = p.stat.question__title,
            title_cn = "",
            title_slug = p.stat.question__title_slug,
            link = ("https://leetcode.%s/problems/%s/"):format(
                config.domain,
                p.stat.question__title_slug
            ),
            paid_only = p.paid_only,
            ac_rate = p.stat.total_acs * 100 / math.max(p.stat.total_submitted, 1),
            difficulty = ({ "Easy", "Medium", "Hard" })(p.difficulty.level),
            starred = p.is_favor,
            topic_tags = {},
        }
    end, problems)
end

return M
