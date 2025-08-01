local config = require("leetcode.config")
local log = require("leetcode.logger")
local urls = require("leetcode.api.urls")
local queries = require("leetcode.api.queries")

---@class leet.api.stats
local M = {}

function M.calendar(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = queries.calendar

    Leet.api.query(query, variables, {
        endpoint = urls.calendar,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local calendar = data["matchedUser"]["calendar"]

            calendar.submission_calendar = vim.json.decode(calendar.submission_calendar)

            cb({ calendar = calendar }, nil)
        end,
    })
end

---@param cb fun(res: lc.Stats.QuestionCount[], err: lc.err)
function M.session_progress(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = queries.session_progress

    Leet.api.query(query, variables, {
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local session_progress = data["matchedUser"]["submitStats"]["acSubmissionNum"]
            cb(session_progress)
        end,
    })
end

---@param cb fun(res: lc.Stats.Res, err: lc.err)
function M.solved(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = queries.solved

    Leet.api.query(query, variables, {
        endpoint = urls.solved,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local questions_count = data["allQuestionsCount"]
            local submit_stats = data["matchedUser"]["submit_stats"]

            cb({
                questions_count = questions_count,
                submit_stats = submit_stats,
            })
        end,
    })
end

---@param cb fun(res: lc.Skills.Res, err: lc.err)
function M.skills(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = queries.skills

    Leet.api.query(query, variables, {
        endpoint = urls.skills,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end
            local data = res.data
            local tag_problems_counts = data["matchedUser"]["tag_problems_counts"]
            cb(tag_problems_counts)
        end,
    })
end

---@param cb fun(res: lc.Languages.Res, err: lc.err)
function M.languages(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = queries.languages

    Leet.api.query(query, variables, {
        endpoint = urls.languages,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end
            local data = res.data
            local lang_prob_count = data["matchedUser"]["languageProblemCount"]
            cb(lang_prob_count)
        end,
    })
end

function M.streak(cb)
    local variables = vim.empty_dict()

    local query = queries.streak

    Leet.api.query(query, variables, {
        endpoint = urls.streak_counter,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end

            local data = res.data
            local streak = data["streakCounter"]

            if streak == vim.NIL then
                err = { msg = "Failed to load streak counter" }
                cb(nil, err)
            else
                cb(streak)
            end
        end,
    })
end

---@param cb fun(res: lc.res.session[], err: lc.err)
function M.sessions(cb)
    local url = urls.session

    Leet.api.post(url, {
        body = vim.empty_dict(),
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end
            config.sessions.update(res.sessions)
            cb(res.sessions)
        end,
    })
end

function M.change_session(id, cb)
    local body = {
        func = "activate",
        target = id,
    }

    local url = urls.session

    Leet.api.put(url, {
        body = body,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end
            config.sessions.update(res.sessions)
            cb(res.sessions)
        end,
    })
end

function M.create_session(name, cb)
    local body = {
        func = "create",
        name = name,
    }

    local url = urls.session

    Leet.api.put(url, {
        body = body,
        callback = function(res, err)
            if err then
                return cb(nil, err)
            end
            config.sessions.update(res.sessions)
            cb(res.sessions)
        end,
    })
end

return M
