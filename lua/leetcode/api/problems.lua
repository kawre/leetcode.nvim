local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local config = require("leetcode.config")
local urls = require("leetcode.api.urls")

local log = require("leetcode.logger")

---@class lc.ProblemsApi
local M = {}

---@return lc.Cache.Question[]
function M.all(cb)
    local endpoint = urls.problems:format("algorithms")

    if cb then
        utils.get(endpoint, function(res, err)
            if err then return end

            local problems = utils.normalize_problems(res.stat_status_pairs)

            if config.is_cn then
                M.translated_titles(function(titles)
                    problems = utils.translate_titles(problems, titles)
                    cb(problems)
                end)
            else
                cb(problems)
            end
        end)
    else
        local res, err = utils.get(endpoint)
        local problems = utils.normalize_problems(res.stat_status_pairs)

        if config.is_cn then
            local titles = M.translated_titles()
            return utils.translate_titles(problems, titles)
        else
            return problems
        end
    end
end

function M.question_of_today(cb)
    local query = queries.qot

    utils.query(query, {}, {
        callback = function(res)
            local tday_record = res.data["todayRecord"]
            local question = config.is_cn and tday_record[1].question or tday_record.question
            cb(question)
        end,
    })
end

function M.translated_titles(cb)
    local query = queries.translations

    if cb then
        utils.query(query, {}, { callback = function(res, err) cb(res.data.translations) end })
    else
        local res, err = utils.query(query, {})
        return res.data.translations
    end
end

return M
