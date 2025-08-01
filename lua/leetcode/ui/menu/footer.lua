local m = require("markup")
local config = require("leetcode.config")
local api = require("leetcode.api.stats")

return m.component(function()
    local streak, set_streak = m.hooks.variable({})
    local win = m.hooks.window()
    local progress, set_progress = m.hooks.variable({})
    local store = m.hooks.use(Leet.auth)

    m.hooks.effect(function()
        if store.auth:isempty() then
            return
        end

        api.session_progress(function(data, err)
            if err then
                Markup.log.error(err)
                return
            end
            set_progress(data)
        end)

        api.streak(function(data, err)
            if err then
                Markup.log.error(err)
                return
            end
            set_streak(data)
        end)

        return win:map("n", "9", function()
            set_streak(function(v)
                return {
                    streakCount = (v.streakCount or 0) + 1,
                    todayCompleted = v.todayCompleted,
                }
            end)
        end)
    end, { store.auth })

    local function stats()
        local res = {}

        local hl = {
            ["Easy"] = "DiagnosticVirtualTextHint",
            ["Medium"] = "DiagnosticVirtualTextInfo",
            ["Hard"] = "DiagnosticVirtualTextError",
        }

        for _, p in ipairs(progress or {}) do
            if p.difficulty ~= "All" then
                table.insert(
                    res,
                    m.block({
                        m.inline("  ", hl[p.difficulty]),
                        m.inline(" " .. p.count),
                    })
                )
            end
        end

        return m.flex({ children = res, spacing = 1 })
    end

    return m.vflex({
        stats(),
        spacing = 1,
        align = "center",
        m.flex({
            spacing = 1,
            m.block({
                m.inline("  ", "DiagnosticVirtualTextError"),
                " ",
                m.inline(streak.streakCount or "󰨕"),
            }),
            m.block({
                m.inline("  ", "DiagnosticVirtualTextInfo"),
                " ",
                m.inline(config.auth.name or "no user", "Statement"),
            }),
        }),
    })
end)
