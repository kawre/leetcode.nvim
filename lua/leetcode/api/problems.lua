local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local config = require("leetcode.config")
local urls = require("leetcode.api.urls")
local Spinner = require("leetcode.logger.spinner")

---@class lc.ProblemsApi
local Problems = {}

---@param cb? function
---@param noti? boolean
---
---@return lc.cache.Question[], lc.err
function Problems.all(cb, noti)
    local endpoint = urls.problems:format("algorithms")

    local spinner
    if noti then
        spinner = Spinner:start("updating problemlist cache", "points")
    end

    if cb then
        utils.get(endpoint, {
            callback = function(res, err)
                if err then
                    if spinner then
                        spinner:error(err.msg)
                    end
                    return cb(nil, err)
                end

                local problems = utils.normalize_problems(res.stat_status_pairs)

                if config.is_cn then
                    if spinner then
                        spinner:update("fetching title translations")
                    end
                    Problems.translated_titles(function(titles, terr)
                        if terr then
                            if spinner then
                                spinner:error(terr.msg)
                            end
                            return cb(nil, terr)
                        end

                        problems = utils.translate_titles(problems, titles)
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
        local res, err = utils.get(endpoint)
        if err then
            if spinner then
                spinner:error(err.msg)
            end
            return nil, err
        end

        local problems = utils.normalize_problems(res.stat_status_pairs)

        if config.is_cn then
            local titles, terr = Problems.translated_titles()
            if terr then
                if spinner then
                    spinner:error(terr.msg)
                end
                return nil, terr
            end

            if spinner then
                spinner:success("problems cache updated")
            end
            return utils.translate_titles(problems, titles)
        else
            if spinner then
                spinner:success("problems cache updated")
            end
            return problems
        end
    end
end

function Problems.question_of_today(cb)
    local query = queries.qot

    utils.query(query, {}, {
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

---@param cb function
function Problems.company_list(cb)
    local query = queries.company_list
    local variables = { ["in"] = { offset = 0, limit = 100 } }

    utils.query(query, variables, {
        endpoint = "/graphql/noj-go",
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data.interviewHotCompanyCards
            local companies = {}
            for _, card in ipairs(data.cards) do
                local tag = card.companyInfo.companyTag
                table.insert(companies, {
                    name = tag.name ~= "" and tag.name or tag.translatedName,
                    slug = tag.slug,
                    question_count = tag.questionCount,
                })
            end
            cb(companies)
        end,
    })
end

---@param company_slug string
---@param cb function
function Problems.company_questions(company_slug, cb)
    local query = queries.company_questions
    local favorite_slug = company_slug .. "-thirty-days"
    local variables = {
        favoriteSlug = favorite_slug,
        skip = 0,
        limit = 500,
        filtersV2 = {
            filterCombineType = "ALL",
            statusFilter = { questionStatuses = {}, operator = "IS" },
            difficultyFilter = { difficulties = {}, operator = "IS" },
            languageFilter = { languageSlugs = {}, operator = "IS" },
            topicFilter = { topicSlugs = {}, operator = "IS" },
            acceptanceFilter = {},
            frequencyFilter = {},
            frontendIdFilter = {},
            lastSubmittedFilter = {},
            publishedFilter = {},
            companyFilter = { companySlugs = {}, operator = "IS" },
            positionFilter = { positionSlugs = {}, operator = "IS" },
            positionLevelFilter = { positionLevelSlugs = {}, operator = "IS" },
            contestPointFilter = { contestPoints = {}, operator = "IS" },
            premiumFilter = { premiumStatus = {} },
        },
        searchKeyword = "",
        sortBy = { sortField = "CUSTOM", sortOrder = "ASCENDING" },
    }

    utils.query(query, variables, {
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data.favoriteQuestionList
            cb(data.questions)
        end,
    })
end

function Problems.translated_titles(cb)
    local query = queries.translations

    if cb then
        utils.query(query, {}, {
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

return Problems
