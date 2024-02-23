---@class lc.Sessions
local Sessions = {}

Sessions.default = "anonymous"
Sessions.names = {}
Sessions.all = {}

---@param sessions lc.res.session[]
function Sessions.update(sessions) --
    Sessions.all = sessions

    while #Sessions.names > 0 do
        table.remove(Sessions.names)
    end

    for _, session in ipairs(sessions) do
        local name = session.name == "" and Sessions.default or session.name
        table.insert(Sessions.names, name:lower())
    end
end

return Sessions
