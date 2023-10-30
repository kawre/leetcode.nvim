local Header = require("leetcode-menu.components.header")
local Text = require("leetcode-ui.component.text")

local NuiLine = require("nui.line")
local NuiText = require("nui.text")

local stats_api = require("leetcode.api.statistics")
local log = require("leetcode.logger")

---@class lc-ui.Calendar : lc-ui.Text
---@field curr_time integer
---@field calendar table<string, integer>
---@field calendar_lines NuiLine[]
---@field last_year_sub_count integer
local Calendar = {}
Calendar.__index = Calendar
setmetatable(Calendar, Text)

local function get_days_in_month(month, year)
    local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then days_in_month[2] = 29 end
    return days_in_month[month]
end

---@param osdate osdate
function Calendar:get_submission(osdate)
    local function is_same_day(date1, date2)
        return date1.year == date2.year and date1.month == date2.month and date1.day == date2.day
    end

    for i, sub in ipairs(self.submissions) do
        if is_same_day(sub.osdate, osdate) then
            table.remove(self.submissions, i)
            return sub.count
        end
    end
end

---@param res lc.Stats.Res
function Calendar:handle_res(res)
    self.calendar = res.calendar

    local time = os.date("*t")
    self.curr_time = os.time({ year = time.year - 1, month = time.month, day = 1 })
    self.time = time
    self.last_year_sub_count = 0
    self.month_lens = {}
    self.max_sub_count = 0

    self.submissions = {}
    for ts, count in pairs(self.calendar.submission_calendar) do
        local osdate = os.date("*t", ts)
        self.max_sub_count = math.max(self.max_sub_count, count)
        table.insert(self.submissions, { osdate = osdate, count = count })
        self.last_year_sub_count = self.last_year_sub_count + count
    end

    self.calendar_lines = {}
    for _ = 1, 7 do
        table.insert(self.calendar_lines, NuiLine())
    end

    self:handle_months()
    self:handle_submissions()
    self.lines = self.calendar_lines
end

function Calendar:handle_submissions()
    local max_len = 0
    for _, line in ipairs(self.calendar_lines) do
        max_len = math.max(vim.api.nvim_strwidth(line:content()), max_len)
    end

    local subs = ("%d submissions"):format(self.last_year_sub_count)
    local active_days = ("active days:  %d"):format(self.calendar.total_active_days)
    local streak = ("max streak: 󰈸 %d"):format(self.calendar.streak)

    local padding = (max_len - vim.api.nvim_strwidth(subs .. active_days .. streak)) / 2

    local sub_line = NuiLine()
    sub_line:append(subs)
    sub_line:append((" "):rep(padding + (padding % 2 == 0 and 1 or 0)))
    sub_line:append(active_days)
    sub_line:append((" "):rep(padding))
    sub_line:append(streak)
    table.insert(self.calendar_lines, sub_line)
end

function Calendar:handle_months()
    for m = 1, 13 do
        if m ~= 1 then
            for i = 1, 7 do
                self.calendar_lines[i]:append(" ")
            end
        end
        self:handle_weeks(m)
    end
end

---@param m integer
function Calendar:handle_weeks(m)
    local curr = os.date("*t", self.curr_time)
    for i = 1, curr.wday - 1 do
        self.calendar_lines[i]:append(" ")
    end

    for _ = 1, get_days_in_month(curr.month, curr.year) do
        self:handle_weekdays(m)
    end

    curr = os.date("*t", self.curr_time)
    for i = curr.wday, 7 do
        self.calendar_lines[i]:append(" ")
    end
end

local function square_hl(count, max_count)
    local perc = (count / max_count) * 100
    local num = math.ceil(perc / 10) * 10
    return ("leetcode_calendar_%d"):format(num)
end

---@param m integer
function Calendar:handle_weekdays(m)
    local curr = os.date("*t", self.curr_time)

    local count = self:get_submission(curr) or 0

    local text = NuiText("󰝤", square_hl(count, self.max_sub_count))
    self.calendar_lines[curr.wday]:append(text)

    self.curr_time = self.curr_time + (60 * 60 * 24)
end

---@param res lc.Stats.Res
function Calendar:init(res, opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Keyword",
        -- padding = {
        --     top = 4,
        --     bot = 2,
        -- },
    }, opts or {})

    self = setmetatable(Text:init({}, opts), self)
    self:handle_res(res)
    return self
end

return Calendar
