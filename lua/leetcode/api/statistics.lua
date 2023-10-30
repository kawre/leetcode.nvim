local utils = require("leetcode.api.utils")
local config = require("leetcode.config")

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

function statistics.solved(cb)
    local variables = {
        username = config.auth.name,
    }

    local query = [[
        query userProfileStatistics($username: String!, $year: Int) {
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
                submit_stats: submitStats {
                    acSubmissionNum {
                        difficulty
                        count
                        submissions
                    }
                    totalSubmissionNum {
                        difficulty
                        count
                        submissions
                    }
                }
            }
        }
    ]]

    utils._query(query, variables, function(res)
        local data = res.body.data
        local calendar = data["matchedUser"]["calendar"]
        local questions_count = data["allQuestionsCount"]
        local submit_stats = data["matchedUser"]["submit_stats"]

        calendar.submission_calendar = select(2, pcall(utils.decode, calendar.submission_calendar))

        cb({
            calendar = calendar,
            questions_count = questions_count,
            submit_stats = submit_stats,
        })
    end)
end

return statistics
