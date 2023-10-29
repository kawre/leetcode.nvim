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

return statistics
