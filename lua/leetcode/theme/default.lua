local M = {}

---Mixes two colors evenly, or returns whichever one exists.
---
---@param a? integer
---@param b? integer
---@return integer?
local function blend(a, b)
    if not a or not b then
        return a or b
    end

    local mixed = 0
    for shift = 0, 16, 8 do
        local channel_a = math.floor(a / 2 ^ shift) % 256
        local channel_b = math.floor(b / 2 ^ shift) % 256
        mixed = mixed + math.floor((channel_a + channel_b) / 2) * 2 ^ shift
    end
    return mixed
end

---Get highlight group value by name.
---
---@param name string String for looking up highlight group.
---@return table
local function hl(name)
    local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
    setmetatable(highlight, {
        __index = function(self, key)
            if key == "bg" then
                return self.background
            end
            if key == "fg" then
                return self.foreground
            end

            return nil
        end,
    })

    return highlight
end

---@alias lc.highlights table<string, vim.api.keyset.highlight>

---@return lc.highlights
M.get = function()
    local mix = Markup.animate.mix
    local bg = hl("Normal").bg or (vim.o.background == "light" and 0xffffff or 0x1e1e2e)
    local fg = hl("Normal").fg or (vim.o.background == "light" and 0x1e1e2e or 0xcdd6f4)

    local surface = mix(bg, fg, 0.06)
    local raised = mix(bg, fg, 0.13)
    local muted = mix(bg, fg, 0.5)
    local light = vim.o.background == "light"

    --- Colors tuned for dark backgrounds lose their contrast on light ones.
    local function readable(color)
        return light and mix(color, 0x000000, 0.35) or color
    end

    local accent = readable(0xffa116)
    local ok = hl("DiagnosticOk").fg or 0x46c6c2
    local err = hl("DiagnosticError").fg or 0xf8615c
    local warn = hl("DiagnosticWarn").fg or 0xfac31d
    local header = mix(hl("CursorLine").bg or raised, 0xffffff, 0.06)
    -- Cards of the description: barely lighter than the panel they sit on,
    -- which is a float.
    local subtle = mix(hl("NormalFloat").bg or bg, fg, 0.035)
    local difficulty = {
        easy = readable(0x46c6c2),
        medium = readable(0xfac31d),
        hard = readable(0xf8615c),
    }

    local groups = {
        [""] = { fg = hl("Normal").fg },

        easy = { fg = difficulty.easy },
        medium = { fg = difficulty.medium },
        hard = { fg = difficulty.hard },

        easy_alt = { fg = "#294d35" },
        medium_alt = { fg = "#5e4e25" },
        hard_alt = { fg = "#5a302f" },

        ok = { fg = hl("DiagnosticOk").fg },
        info = { fg = hl("DiagnosticInfo").fg },
        hint = { fg = hl("DiagnosticHint").fg },
        error = { fg = hl("DiagnosticError").fg },

        case_ok = { fg = hl("DiagnosticOk").fg, bg = hl("Normal").bg, bold = true },
        case_err = { fg = hl("DiagnosticError").fg, bg = hl("Normal").bg, bold = true },

        case_focus_ok = { bg = hl("DiagnosticOk").fg, fg = hl("NormalSB").bg, bold = true },
        case_focus_err = { bg = hl("DiagnosticError").fg, fg = hl("NormalSB").bg, bold = true },

        normal = { fg = hl("Conceal").fg },
        alt = { fg = hl("Comment").fg },
        description_header = { bg = header },
        header_track = { fg = mix(header, fg, 0.15) },
        -- Separators beside the header keep their own color on its background.
        header_separator = { fg = hl("WinSeparator").fg or muted, bg = header },
        section = { bg = subtle },

        italic = { italic = true },
        bold = { bold = true },
        underline = { underline = true },

        -- A step up from the cards, so it stands out on them and beside them.
        code = { fg = hl("Type").fg, bg = mix(subtle, fg, 0.08) },
        example = { fg = hl("DiagnosticHint").fg },
        constraints = { fg = hl("DiagnosticInfo").fg },
        header = { fg = hl("SpecialChar").fg, bold = true },
        followup = { fg = hl("Number").fg, bold = true },

        link = { fg = hl("Function").fg, underline = true },
        list = { fg = hl("SpecialChar").fg },
        ref = { fg = hl("Tag").fg },
        su = { fg = hl("Number").fg },

        -- calendar
        calendar_0 = { fg = "#45475b" },
        calendar_10 = { fg = "#004d1b" },
        calendar_20 = { fg = "#016620" },
        calendar_30 = { fg = "#078029" },
        calendar_40 = { fg = "#109932" },
        calendar_50 = { fg = "#1cb33d" },
        calendar_60 = { fg = "#28c244" },
        calendar_70 = { fg = "#51d164" },
        calendar_80 = { fg = "#7fe18b" },
        calendar_90 = { fg = "#b3f0b8" },
        calendar_100 = { fg = "#d8ffda" },

        all = { fg = hl("Normal").fg },
        all_alt = { fg = "#45475b" },

        -- surfaces
        surface = { bg = surface },
        row_active = { bg = raised },
        muted = { fg = muted },
        accent = { fg = accent },
        strong = { fg = fg, bold = true },
        key = { fg = mix(bg, accent, light and 1 or 0.75) },
        track = { bg = raised },
        divider = { fg = raised },
        flame = { fg = accent },
        flame_off = { fg = muted },

        -- verdicts
        -- The status of a run in the console's header, text on its band.
        status_ok = { fg = ok, bold = true },
        status_error = { fg = err, bold = true },
        status_warn = { fg = warn, bold = true },
        verdict_ok = { fg = ok, bg = mix(bg, ok, 0.16), bold = true },
        verdict_error = { fg = err, bg = mix(bg, err, 0.16), bold = true },
        verdict_warn = { fg = warn, bg = mix(bg, warn, 0.16), bold = true },
        bar_ok = { fg = ok, bg = raised },
        bar_error = { fg = err, bg = raised },
        bar_accent = { fg = accent, bg = raised },
        diff_add = { fg = ok, bg = mix(bg, ok, 0.25), bold = true },
        diff_delete = { fg = err, bg = mix(bg, err, 0.25), bold = true },

        -- buttons
        tab = { fg = muted, bg = surface },
        tab_active = { fg = bg, bg = accent, bold = true },
        -- The console. Its tabs are text on the band of the header, the one shown
        -- a chip warmed by the accent with its icon in it, and its cases quiet
        -- chips below them, so the accent marks only where you are.
        console_tab = { fg = muted, bg = header },
        console_tab_hover = { fg = fg, bg = mix(header, fg, 0.08) },
        console_tab_active = { fg = mix(fg, accent, 0.3), bg = mix(header, accent, 0.18), bold = true },
        console_tab_active_hover = { fg = mix(fg, accent, 0.3), bg = mix(header, accent, 0.26), bold = true },
        console_case = { fg = muted },
        console_case_hover = { fg = fg, bg = surface },
        console_case_active = { fg = fg, bg = raised, bold = true },
        console_case_active_hover = { fg = fg, bg = mix(raised, fg, 0.22), bold = true },
        tab_ok = { fg = ok, bg = surface },
        tab_error = { fg = err, bg = surface },
        tab_ok_active = { fg = bg, bg = ok, bold = true },
        tab_error_active = { fg = bg, bg = err, bold = true },
    }

    for name, color in pairs(difficulty) do
        groups["pill_" .. name] = { fg = color, bg = mix(bg, color, 0.18) }
        groups["pill_" .. name .. "_cap"] = { fg = mix(bg, color, 0.18) }
        groups["bar_" .. name] = { fg = color, bg = raised }
    end

    -- An input is a solid block, and lighter while it has the cursor.
    groups.input = { fg = fg, bg = mix(bg, fg, 0.09) }
    groups.input_focus = { fg = fg, bg = mix(bg, fg, 0.17) }

    -- What changes every day gets a warmth of its own.
    groups.daily = { bg = mix(surface, accent, 0.1) }
    groups.daily_active = { bg = mix(raised, accent, 0.2) }

    groups.pill_accent = { fg = bg, bg = accent, bold = true }
    groups.pill_accent_cap = { fg = accent }
    groups.rule = { fg = mix(bg, accent, 0.45) }

    -- Heatmap cells are half blocks, so each pair of days is a group. Level 0 is a
    -- day without activity. A day that is not there has no color at all, so the
    -- card shows through whatever its color, such as while it is lifted.
    local heat = { [0] = raised }
    for level = 1, 4 do
        heat[level] = mix(raised, ok, level / 4)
    end
    for top = 0, 4 do
        groups[("heat_%d_x"):format(top)] = { fg = heat[top] }
        groups[("heat_x_%d"):format(top)] = { fg = heat[top] }
        for bottom = 0, 4 do
            groups[("heat_%d_%d"):format(top, bottom)] = { fg = heat[top], bg = heat[bottom] }
        end
    end

    return groups
end

return M
