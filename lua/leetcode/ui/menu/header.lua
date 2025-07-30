local m = require("markup")
local api = require("leetcode.api.statistics")

local ascii = vim.tbl_map(m.block, {
    [[ /$$                          /$$     /$$$$$$                /$$         ]],
    [[| $$                         | $$    /$$__  $$              | $$         ]],
    [[| $$       /$$$$$$  /$$$$$$ /$$$$$$ | $$  \__/ /$$$$$$  /$$$$$$$ /$$$$$$ ]],
    [[| $$      /$$__  $$/$$__  $|_  $$_/ | $$      /$$__  $$/$$__  $$/$$__  $$]],
    [[| $$     | $$$$$$$| $$$$$$$$ | $$   | $$     | $$  \ $| $$  | $| $$$$$$$$]],
    [[| $$     | $$_____| $$_____/ | $$ /$| $$    $| $$  | $| $$  | $| $$_____/]],
    [[| $$$$$$$|  $$$$$$|  $$$$$$$ |  $$$$|  $$$$$$|  $$$$$$|  $$$$$$|  $$$$$$$]],
    [[|________/\_______/\_______/  \___/  \______/ \______/ \_______/\_______/]],
})

local function is_same_day(date1, date2)
    return date1.year == date2.year and date1.month == date2.month and date1.day == date2.day
end

local month_names = {
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
}

local function get_days_in_month(month, year)
    local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
        days_in_month[2] = 29
    end
    return days_in_month[month]
end

return m.component(function()
    local calendar, set_calendar = m.hooks.variable({})

    m.hooks.effect(function()
        api.calendar(function(data)
            local time = os.date("*t")
            local curr = os.time(vim.tbl_extend("force", time, {
                year = time.year - 1,
                month = time.month,
                day = time.day,
                hour = 1,
                isdst = false,
            }))

            local threshold = os.time({
                year = time.year,
                month = time.month,
                day = time.day,
                hour = 1,
                isdst = false,
            })
            if threshold <= os.time(time) then
                threshold = threshold + 24 * 60 * 60
            end

            local last_year_sub_count = 0
            local month_lens = {}
            local max_sub_count = 0
            local submissions = {}

            for ts, count in pairs(data.calendar.submission_calendar) do
                local osdate = os.date("*t", tonumber(ts))
                max_sub_count = math.max(max_sub_count, count)
                table.insert(submissions, { osdate = osdate, count = count })
                last_year_sub_count = last_year_sub_count + count
            end

            local months = {}
            local ordered_keys = {} -- ✅ Declare here

            local t = os.date("*t")
            for i = 11, 0, -1 do
                local past = os.date(
                    "*t",
                    os.time({
                        year = t.year,
                        month = t.month - i,
                        day = 1,
                    })
                )
                local key = string.format("%04d-%02d", past.year, past.month)
                if not months[key] then
                    months[key] = {}
                end
                table.insert(ordered_keys, key)
            end

            for _, sub in ipairs(submissions) do
                local osdate = sub.osdate
                local count = sub.count

                local month_key = string.format("%04d-%02d", osdate.year, osdate.month)
                months[month_key] = months[month_key] or {}

                local first_day_of_month = os.time({
                    year = osdate.year,
                    month = osdate.month,
                    day = 1,
                    hour = 0,
                })
                local first_wday = os.date("*t", first_day_of_month).wday

                local week_num = math.floor((osdate.day + first_wday - 2) / 7) + 1

                months[month_key][week_num] = months[month_key][week_num] or {}
                months[month_key][week_num][osdate.day] = count
            end

            set_calendar({
                calendar = data.calendar,
                curr_time = curr,
                months = months,
                threshold = threshold,
                last_year_sub_count = last_year_sub_count,
                month_lens = month_lens,
                max_sub_count = max_sub_count,
                submissions = submissions,
                ordered_keys = ordered_keys, -- ✅ Pass it along
            })
        end)
    end, {})

    if vim.tbl_isempty(calendar or {}) then
        return "loading..."
    end

    -- Example: render grouped structure
    return m.vflex({
        align = "center",
        margin_top = 3,
        height = 8,
        m.inline("  leetcode.nvim ", "DiagnosticVirtualTextWarn"),
        m.flex({
            spacing = 1,
            margin = 1,
            align = "end",
            vim.tbl_map(function(month_key)
                local year, month_idx = month_key:match("^(%d+)-(%d+)$")
                year = tonumber(year)
                month_idx = tonumber(month_idx)

                local month = calendar.months[month_key]

                local days_in_month = get_days_in_month(month_idx, year)
                local first_day = os.time({
                    year = year,
                    month = month_idx,
                    day = 1,
                    hour = 0,
                })
                local first_wday = os.date("*t", first_day).wday

                -- Fill cells
                local day_cells = {}

                -- Leading blanks
                for _ = 1, first_wday - 1 do
                    table.insert(day_cells, { day = nil })
                end

                -- Days
                for day = 1, days_in_month do
                    local count = 0
                    for _, week_days in pairs(month) do
                        if week_days[day] then
                            count = week_days[day]
                            break
                        end
                    end
                    table.insert(day_cells, { day = day, count = count })
                end

                -- Pad to full weeks
                local rem = #day_cells % 7
                if rem ~= 0 then
                    for _ = 1, 7 - rem do
                        table.insert(day_cells, { day = nil })
                    end
                end

                -- Split into week blocks (each is a row of 7 days)
                local week_blocks = {}
                for i = 1, #day_cells, 7 do
                    local week_days = {}
                    for j = 0, 6 do
                        local cell = day_cells[i + j]
                        table.insert(
                            week_days,
                            m.block(
                                cell.day and "󰨕" or " ",
                                cell.count and cell.count > 0 and "DiagnosticOk" or nil
                            )
                        )
                    end
                    table.insert(week_blocks, m.block({ week_days }))
                end

                -- Month block: title + grid of weeks
                return m.block({
                    m.block(month_names[month_idx], "DiagnosticVirtualTextInfo"),
                    m.flex(week_blocks, "SignColumn"),
                })
            end, calendar.ordered_keys),
        }),
    })
end)
