local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local config = require("leetcode.config")

local log = require("leetcode.logger")

---@class lc.ProblemsApi
local M = {}

---@return lc.Cache.Question[]
function M.all(cb)
    local url = ("%s/api/problems/algorithms/"):format(config.domain)

    if cb then
        utils.get(url, function(res, err)
            if err then return end

            local problems = utils.normalize_problems(res.stat_status_pairs)

            if config.is_cn and config.user.cn.translate then
                M.translated_titles(function(titles)
                    problems = utils.translate_titles(problems, titles)
                    cb(problems)
                end)
            else
                cb(problems)
            end
        end)
    else
        local res, err = utils.get(url)
        local problems = utils.normalize_problems(res.stat_status_pairs)

        if config.is_cn and config.user.cn.translate then
            local titles = M.translated_titles()
            return utils.translate_titles(problems, titles)
        else
            return problems
        end
    end
end

function M.question_of_today(cb)
    local query = queries.qot()

    local callback = function(res)
        local question = res.data["activeDailyCodingChallengeQuestion"]["question"]
        cb(question)
    end

    utils.query(query, {}, callback)
end

function M.translated_titles(cb)
    local query = queries.translations()

    if cb then
        utils.query(query, {}, function(res, err) cb(res.data.translations) end)
    else
        local res, err = utils.query(query, {})
        return res.data.translations
    end
end

return M
