---@class lc.Stats
local Stats = {}

Stats.daily = {} ---@type { streak?: number, today_completed?: boolean }
Stats.progress = {} ---@type table<string, lc.Stats.QuestionCount>

function Stats.update_streak()
    local stats_api = require("leetcode.api.statistics")
    local log = require("leetcode.logger")

    stats_api.streak(function(res, err)
        if err then return log.err(err) end

        Stats.daily.streak = res.streakCount
        Stats.daily.today_completed = res.todayCompleted

        if _Lc_menu then _Lc_menu:draw() end
    end)
end

function Stats.update_sessions()
    local stats_api = require("leetcode.api.statistics")
    local log = require("leetcode.logger")

    Stats.progress = {}

    stats_api.sessions(function(_, err)
        if err then return log.err(err) end
        if _Lc_menu then _Lc_menu:draw() end
    end)

    stats_api.session_progress(function(res, err)
        if err then return log.err(err) end

        Stats.progress = {}

        local progress = res
        for _, p in ipairs(progress) do
            Stats.progress[p.difficulty:lower()] = p
        end

        if _Lc_menu then _Lc_menu:draw() end
    end)
end

function Stats.update()
    Stats.update_streak()
    Stats.update_sessions()

    if _Lc_menu then _Lc_menu:draw() end
end

return Stats
