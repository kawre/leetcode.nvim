local log = require("leetcode.logger")
local config = require("leetcode.config")
local statistics = require("leetcode.api.statistics")
local queries = require("leetcode.api.queries")
local urls = require("leetcode.api.urls")
local utils = require("leetcode.api.utils")
local cn_utils = require("leetcode-plugins.cn.utils")

---@param cb fun(res: lc.Stats.Res|nil, err: lc.err)
statistics.solved = function(cb) ---@diagnostic disable-line
    local variables = {
        username = config.auth.name,
    }

    local query = queries.solved

    utils.query(query, variables, {
        endpoint = urls.solved,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local submit_stats = data["submit_stats"]
            local stats = cn_utils.calc_question_count(submit_stats)

            cb(stats, nil)
        end,
    })
end

---@param cb fun(res: lc.Stats.QuestionCount[], err: lc.err)
statistics.session_progress = function(cb)
    local variables = {
        userSlug = config.auth.name,
    }

    local query = queries.session_progress

    utils.query(query, variables, {
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local session_progress = data["userProfileUserQuestionProgress"]["numAcceptedQuestions"]
            cb(session_progress)
        end,
    })
end

statistics.calendar = function(cb) ---@diagnostic disable-line
    local variables = {
        username = config.auth.name,
    }

    local query = queries.calendar

    utils.query(query, variables, {
        endpoint = urls.calendar,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local calendar = data["calendar"]

            calendar.submission_calendar =
                select(2, pcall(utils.decode, calendar.submission_calendar))

            cb({
                calendar = calendar,
            }, nil)
        end,
    })
end

---@param cb fun(res: lc.Languages.Res|nil, err: lc.err)
statistics.languages = function(cb) ---@diagnostic disable-line
    local variables = {
        username = config.auth.name,
    }

    local query = queries.languages

    utils.query(query, variables, {
        endpoint = urls.languages,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local lang_prob_count = data["languageProblemCount"]
            cb(lang_prob_count)
        end,
    })
end
