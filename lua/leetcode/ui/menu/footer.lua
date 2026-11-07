local m = require("markup")
local api = require("leetcode.api.stats")

return m.component(function()
    local streak = m.signal({})
    local progress = m.signal({})

    m.effect(function()
        Leet.menu.stats_version()

        if not Leet.auth() then
            return
        end

        api.session_progress(function(data, err)
            if err then
                Markup.log.error(err)
                return
            end
            progress(data)
        end)

        api.streak(function(data, err)
            if err then
                Markup.log.error(err)
                return
            end
            streak(data)
        end)
    end)

    local function stats()
        local res = {}

        local hl = {
            ["Easy"] = "DiagnosticVirtualTextHint",
            ["Medium"] = "DiagnosticVirtualTextInfo",
            ["Hard"] = "DiagnosticVirtualTextError",
        }

        for _, p in ipairs(progress() or {}) do
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
        stats,
        spacing = 1,
        align = "center",
        m.flex({
            spacing = 1,
            m.block({
                m.inline("  ", "DiagnosticVirtualTextError"),
                " ",
                m.inline(function()
                    return streak().streakCount or "󰨕"
                end),
            }),
            m.block({
                m.inline("  ", "DiagnosticVirtualTextInfo"),
                " ",
                m.inline(function()
                    local auth = Leet.auth()
                    return auth and auth.name or "no user"
                end, "Statement"),
            }),
        }),
    })
end)
