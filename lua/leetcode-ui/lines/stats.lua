local Lines = require("leetcode-ui.lines")
local t = require("leetcode.translator")
local log = require("leetcode.logger")
local stats_api = require("leetcode.api.statistics")

---@class lc.ui.menu.Stats : lc.ui.Lines
---@field streak? integer
---@field today_completed? boolean
local Stats = Lines:extend("LeetMenuTitle")

function Stats:contents()
    self:clear()

    local hl = self.today_completed and "leetcode_hard" or "leetcode_alt"
    self:append("󰈸 ", hl)
    self:append(self.streak and tostring(self.streak) or "-")

    return Stats.super.contents(self)
end

function Stats:update()
    stats_api.streak(function(res, err)
        if err then return log.err(err) end

        self.streak = res.streakCount
        self.today_completed = res.todayCompleted

        if _Lc_Menu then _Lc_Menu:draw() end
    end)
end

function Stats:init() --
    Stats.super.init(self, {}, {})

    self:update()
end

---@type fun(): lc.ui.menu.Stats
local LeetMenuStats = Stats

return LeetMenuStats()
