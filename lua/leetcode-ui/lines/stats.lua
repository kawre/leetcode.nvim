local Lines = require("leetcode-ui.lines")
local t = require("leetcode.translator")
local log = require("leetcode.logger")
local stats_api = require("leetcode.api.statistics")
local cmd = require("leetcode.command")
local config = require("leetcode.config")

---@class lc.ui.menu.Stats : lc.ui.Lines
---@field streak? integer
---@field today_completed? boolean
---@field progress? table<string, lc.Stats.QuestionCount>
local Stats = Lines:extend("LeetMenuTitle")

function Stats:contents()
    self:clear()

    local hl = self.today_completed and "leetcode_hard" or "leetcode_alt"
    self:append("󰈸 ", hl)
    self:append(self.streak and tostring(self.streak) or "-")

    self:append((" %s "):format(config.icons.bar))

    self:append(t("session") .. ": ", "leetcode_alt")
    local session = cmd.get_active_session()
    local session_name = session
            and (session.name == "" and config.sessions.default or session.name)
        or "-"
    self:append(session_name)

    local function create_progress(key)
        self:append("   ", "leetcode_" .. key)
        local count = self.progress[key] and tostring(self.progress[key].count) or "-"
        self:append(count)
    end

    create_progress("easy")
    create_progress("medium")
    create_progress("hard")

    return Stats.super.contents(self)
end

function Stats:update_streak()
    stats_api.streak(function(res, err)
        if err then return log.err(err) end

        self.streak = res.streakCount
        self.today_completed = res.todayCompleted

        if _Lc_menu then _Lc_menu:draw() end
    end)
end

function Stats:update_sessions()
    self.progress = {}

    stats_api.sessions(function(_, err)
        if err then return log.err(err) end
        if _Lc_menu then _Lc_menu:draw() end
    end)

    stats_api.session_progress(function(res, err)
        if err then return log.err(err) end

        self.progress = {}

        local progress = res
        for _, p in ipairs(progress) do
            self.progress[p.difficulty:lower()] = p
        end

        if _Lc_menu then _Lc_menu:draw() end
    end)
end

function Stats:update()
    self:update_streak()
    self:update_sessions()

    if _Lc_menu then _Lc_menu:draw() end
end

function Stats:init(...)
    Stats.super.init(self, ...)

    self.progress = {}
end

---@type fun(): lc.ui.menu.Stats
local LeetMenuStats = Stats

return LeetMenuStats()
