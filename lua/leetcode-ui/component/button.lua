local component = require("leetcode-ui.component")
local log = require("leetcode.logger")
local Line = require("nui.line")

---@class lc-ui.Button: lc-ui.Component
local button = {}
button.__index = button
setmetatable(button, component)

---@class lc-ui.Button.text
---@field icon string
---@field src string

--- @param text lc-ui.Button.text
--- @param sc string
--- @param on_press function? optional
--- @param expandable boolean? optional
--- @param keybind string? optional
--- @param keybind_opts table? optional
function button:init(text, sc, on_press, expandable, keybind, keybind_opts)
    -- local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

    local opts = {
        position = "center",
        on_press = on_press or function() end,
    }
    local width = 40

    local line = Line()
    local padding = string.rep(" ", width - text.src:len() - sc:len() - 3)
    -- line:append(string.format("%s ", icon))
    line:append("x " .. text.src .. (expandable and "_" or " ") .. padding .. sc)
    -- txt = string.format("%s%s%s", icon, " " .. txt, expandable and "…" or "")
    -- line:append(txt .. padding .. sc)

    local o = setmetatable({
        opts = opts,
        lines = { line },
    }, self)

    self.lines = o.lines
    self.opts = o.opts

    return o
end

return button
