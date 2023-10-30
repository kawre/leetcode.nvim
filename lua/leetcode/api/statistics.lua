local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

local statistics = {}

function statistics.calendar(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = [[
        query userProfileCalendar($username: String!, $year: Int) {
            matchedUser(username: $username) {
                userCalendar(year: $year) {
                    active_years: activeYears
                    streak
                    total_active_days: totalActiveDays
                    dcc_badges: dccBadges {
                        timestamp
                        badge {
                            name
                            icon
                        }
                    }
                    submission_calendar: submissionCalendar
                }
            }
        }
    ]]

    utils._query(query, variables, function(res)
        local data = res.body.data
        local calendar = data["matchedUser"]["userCalendar"]

        calendar.submission_calendar = select(2, pcall(utils.decode, calendar.submission_calendar))

        cb(calendar)
    end)
end

---@param cb fun(res: lc.Stats.Res)
function statistics.solved(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = [[
        query userStatistics($username: String!, $year: Int) {
            allQuestionsCount {
                difficulty
                count
            }
            matchedUser(username: $username) {
                calendar: userCalendar(year: $year) {
                    active_years: activeYears
                    streak
                    total_active_days: totalActiveDays
                    dcc_badges: dccBadges {
                        timestamp
                        badge {
                            name
                            icon
                        }
                    }
                    submission_calendar: submissionCalendar
                }
                solved_beats: problemsSolvedBeatsStats {
                    difficulty
                    percentage
                }
                submit_stats: submitStatsGlobal {
                    acSubmissionNum {
                        difficulty
                        count
                    }
                }
            }
        }
    ]]

    utils._query(query, variables, function(res)
        local data = res.body.data

        local questions_count = data["allQuestionsCount"]
        local calendar = data["matchedUser"]["calendar"]
        local submit_stats = data["matchedUser"]["submit_stats"]
        local solved_beats = data["matchedUser"]["solved_beats"]

        calendar.submission_calendar = select(2, pcall(utils.decode, calendar.submission_calendar))

        cb({
            calendar = calendar,
            questions_count = questions_count,
            submit_stats = submit_stats,
            solved_beats = solved_beats,
        })
    end)
end

---@param cb fun(res: lc.Skills.Res)
function statistics.skills(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = [[
        query skillStats($username: String!) {
            matchedUser(username: $username) {
                tag_problems_counts: tagProblemCounts {
                    advanced {
                        tag: tagName
                        slug: tagSlug
                        problems_solved: problemsSolved
                    }
                    intermediate {
                        tag: tagName
                        slug: tagSlug
                        problems_solved: problemsSolved
                    }
                    fundamental {
                        tag: tagName
                        slug: tagSlug
                        problems_solved: problemsSolved
                    }
                }
            }
        }
    ]]

    utils._query(query, variables, function(res)
        local data = res.body.data
        local tag_problems_counts = data["matchedUser"]["tag_problems_counts"]
        cb(tag_problems_counts)
    end)
end

---@param cb fun(res: lc.Languages.Res)
function statistics.languages(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = [[
        query languageStats($username: String!) {
            matchedUser(username: $username) {
                languageProblemCount {
                    lang: languageName
                    problems_solved: problemsSolved
                }
            }
        }
    ]]

    utils._query(query, variables, function(res)
        local data = res.body.data
        local lang_prob_count = data["matchedUser"]["languageProblemCount"]
        cb(lang_prob_count)
    end)
end

return statistics
