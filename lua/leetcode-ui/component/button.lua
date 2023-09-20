local component = require("leetcode-ui.component")
local log = require("leetcode.logger")
local Line = require("nui.line")

---@class lc.db.Button: lc.db.Component
local button = {}
button.__index = button
setmetatable(button, component)

--- @param sc string
--- @param txt string
--- @param icon string
--- @param expandable boolean? optional
--- @param keybind string? optional
--- @param keybind_opts table? optional
function button:init(sc, txt, icon, expandable, keybind, keybind_opts)
    -- local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

    local opts = {
        position = "center",
    }
    local width = 40

    local line = Line()
    local padding = string.rep(" ", width - txt:len() - sc:len() - 3)
    -- line:append(string.format("%s ", icon))
    line:append("x " .. txt .. (expandable and "_" or " ") .. padding .. sc)
    -- txt = string.format("%s%s%s", icon, " " .. txt, expandable and "…" or "")
    -- line:append(txt .. padding .. sc)

    local o = setmetatable({
        opts = opts,
        lines = { line },
    }, button)

    self.lines = o.lines
    self.opts = o.opts

    return o
end

return button
